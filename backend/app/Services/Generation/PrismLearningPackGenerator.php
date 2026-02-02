<?php

namespace App\Services\Generation;

use App\Models\Document;
use Prism\Prism\Enums\Provider;
use Prism\Prism\Facades\Prism;
use Prism\Prism\ValueObjects\Media\Image;
use RuntimeException;

class PrismLearningPackGenerator implements LearningPackGeneratorInterface
{
    public function generate(Document $document, array $concepts): array
    {
        $model = config('prism.openrouter.text_model', 'google/gemini-3-flash-preview');

        if (! config('prism.providers.openrouter.api_key')) {
            throw new RuntimeException('OpenRouter API key is not configured.');
        }

        $additionalContent = $this->imageContentForDocument($document);
        $prompt = $this->buildPrompt($document, $concepts, ! empty($additionalContent));

        $response = Prism::text()
            ->using(Provider::OpenRouter, $model)
            ->withSystemPrompt($this->systemPrompt())
            ->withPrompt($prompt, $additionalContent)
            ->withMaxTokens(1200)
            ->usingTemperature(0.3)
            ->asText();

        $content = $response->text;
        $decoded = json_decode($content, true);

        if (! is_array($decoded)) {
            $decoded = $this->extractJson($content);
        }

        if (! is_array($decoded)) {
            $decoded = $this->repairJson($content);
        }

        if (! is_array($decoded)) {
            throw new RuntimeException('Learning pack generation failed: invalid JSON.');
        }

        return $this->normalizeDifficulty($decoded);
    }

    protected function systemPrompt(): string
    {
        return 'You are an educational content generator. Return only valid JSON.';
    }

    protected function buildPrompt(Document $document, array $concepts, bool $hasImage): string
    {
        $conceptList = array_map(function (array $concept) {
            $key = $concept['concept_key'] ?? $concept['key'] ?? 'concept';
            $label = $concept['concept_label'] ?? $concept['label'] ?? $key;
            $difficulty = $concept['difficulty'] ?? 0.5;

            return "{$key} ({$label}, difficulty {$difficulty})";
        }, $concepts);

        $conceptText = implode(', ', $conceptList);
        $sourceText = $document->extracted_text ?? '';
        $imageNote = $hasImage
            ? 'An image is attached. Read it and use its content as the source of truth.'
            : 'No image is attached.';

        return <<<PROMPT
Create a JSON learning pack for a child aged 10-14.
Use the same language as the source text below for all fields.
If a language is provided in context, use it. Do not use English unless the source text or context is English.
All difficulty values must be between 0 and 1 (inclusive).
If source text is empty, rely on the attached image (if present) to infer the content.
Use ONLY this JSON schema (no markdown, no extra text):
{
  "objective": string,
  "summary": string,
  "language": string,
  "difficulty": number,
  "topics": [string],
  "estimated_time_minutes": number,
  "engagement": {"tone": string, "persona": string, "encouragement": string},
  "concepts": [{"key": string, "label": string, "difficulty": number}],
  "items": [
    {"type": "flashcards"|"quiz"|"matching"|"true_false"|"fill_blank"|"ordering"|"multiple_select"|"short_answer", "content": object}
  ]
}

Concepts: {$conceptText}
Context:
- Subject: {$document->subject}
- Grade: {$document->grade_level}
- Language: {$document->language}
- Goal: {$document->learning_goal}
- Notes: {$document->context_text}
Image: {$imageNote}
Source text: {$sourceText}

Return valid JSON only.
PROMPT;
    }

    /**
     * @return array<int, Image>
     */
    protected function imageContentForDocument(Document $document): array
    {
        if (! $this->isImage($document->mime_type, $document->storage_path, $document->original_filename)) {
            return [];
        }

        $path = $document->storage_path;
        if (! $path) {
            return [];
        }

        if (filter_var($path, FILTER_VALIDATE_URL) !== false) {
            return [Image::fromUrl($path, $document->mime_type)];
        }

        $disk = $document->storage_disk ?: config('filesystems.default', 's3');

        return [Image::fromStoragePath($path, $disk)];
    }

    protected function isImage(?string $mimeType, ?string $path, ?string $filename): bool
    {
        if (is_string($mimeType) && str_starts_with($mimeType, 'image/')) {
            return true;
        }

        $extension = $this->extensionFromPath($path) ?: $this->extensionFromPath($filename);
        if (! $extension) {
            return false;
        }

        $imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'tiff', 'heic'];

        return in_array($extension, $imageExtensions, true);
    }

    protected function extensionFromPath(?string $path): ?string
    {
        if (! $path) {
            return null;
        }

        $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));

        return $extension !== '' ? $extension : null;
    }

    protected function repairJson(string $content): ?array
    {
        $model = config('prism.openrouter.text_model', 'google/gemini-3-flash-preview');
        $schema = <<<'SCHEMA'
{
  "objective": string,
  "summary": string,
  "concepts": [{"key": string, "label": string, "difficulty": number}],
  "items": [
    {"type": "flashcards"|"quiz"|"matching", "content": object}
  ]
}
SCHEMA;

        $prompt = <<<PROMPT
You are given a response that should be JSON but is not valid JSON.
Fix it to match this schema exactly and output JSON only, no markdown:
{$schema}

Input:
{$content}
PROMPT;

        $response = Prism::text()
            ->using(Provider::Mistral, $model)
            ->withSystemPrompt('Return only valid JSON. Do not include any other text.')
            ->withPrompt($prompt)
            ->withMaxTokens(1200)
            ->usingTemperature(0.0)
            ->asText();

        $fixed = json_decode($response->text, true);

        if (! is_array($fixed)) {
            $fixed = $this->extractJson($response->text);
        }

        return is_array($fixed) ? $fixed : null;
    }

    protected function extractJson(string $content): ?array
    {
        if (preg_match('/```json\\s*(\\{.*\\})\\s*```/s', $content, $match) === 1) {
            return json_decode($match[1], true);
        }

        if (preg_match('/```\\s*(\\{.*\\})\\s*```/s', $content, $match) === 1) {
            return json_decode($match[1], true);
        }

        $start = strpos($content, '{');
        $end = strrpos($content, '}');

        if ($start === false || $end === false || $end <= $start) {
            return null;
        }

        $snippet = substr($content, $start, $end - $start + 1);

        return json_decode($snippet, true);
    }

    protected function normalizeDifficulty(array $payload): array
    {
        if (isset($payload['difficulty'])) {
            $payload['difficulty'] = $this->clampDifficulty($payload['difficulty']);
        }

        if (isset($payload['concepts']) && is_array($payload['concepts'])) {
            foreach ($payload['concepts'] as $index => $concept) {
                if (is_array($concept) && isset($concept['difficulty'])) {
                    $payload['concepts'][$index]['difficulty'] = $this->clampDifficulty($concept['difficulty']);
                }
            }
        }

        if (isset($payload['items']) && is_array($payload['items'])) {
            foreach ($payload['items'] as $itemIndex => $item) {
                if (! is_array($item) || ! isset($item['content']) || ! is_array($item['content'])) {
                    continue;
                }
                $payload['items'][$itemIndex]['content'] = $this->normalizeDifficultyInContent($item['content']);
            }
        }

        return $payload;
    }

    protected function normalizeDifficultyInContent(array $content): array
    {
        foreach ($content as $key => $value) {
            if (is_array($value)) {
                $content[$key] = $this->normalizeDifficultyInContent($value);
            } elseif ($key === 'difficulty') {
                $content[$key] = $this->clampDifficulty($value);
            }
        }

        return $content;
    }

    protected function clampDifficulty(mixed $value): float
    {
        if (! is_numeric($value)) {
            return 0.5;
        }

        $number = (float) $value;

        if ($number < 0) {
            return 0.0;
        }

        if ($number > 1) {
            return 1.0;
        }

        return $number;
    }
}
