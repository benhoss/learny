<?php

namespace App\Services\Generation;

use App\Concerns\RetriesLlmCalls;
use App\Models\Document;
use Prism\Prism\Enums\Provider;
use Prism\Prism\Facades\Prism;
use Prism\Prism\ValueObjects\Media\Image;
use RuntimeException;

class PrismLearningPackGenerator implements LearningPackGeneratorInterface
{
    use RetriesLlmCalls;
    public function generate(Document $document, array $concepts): array
    {
        $model = config('prism.openrouter.text_model', 'google/gemini-3-flash-preview');

        if (! config('prism.providers.openrouter.api_key')) {
            throw new RuntimeException('OpenRouter API key is not configured.');
        }

        $additionalContent = $this->imageContentForDocument($document);
        $prompt = $this->buildPrompt($document, $concepts, ! empty($additionalContent));

        $response = $this->callWithRetry(function () use ($model, $prompt, $additionalContent) {
            return Prism::text()
                ->using(Provider::OpenRouter, $model)
                ->withSystemPrompt($this->systemPrompt())
                ->withPrompt($prompt, $additionalContent)
                ->withMaxTokens(1200)
                ->usingTemperature(0.3)
                ->asText();
        });

        $content = $response->text;
        $decoded = json_decode($content, true);

        if (! is_array($decoded)) {
            $decoded = $this->extractJson($content);
        }

        if (! is_array($decoded)) {
            $decoded = $this->repairJson($content, $this->learningPackSchema());
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
        $paths = array_filter(array_merge(
            [$document->storage_path],
            is_array($document->storage_paths ?? null) ? $document->storage_paths : []
        ));
        $mimeTypes = array_filter(array_merge(
            [$document->mime_type],
            is_array($document->mime_types ?? null) ? $document->mime_types : []
        ));

        if (! $this->isImage($mimeTypes, $paths, $document->original_filename)) {
            return [];
        }
        $images = [];
        $disk = $document->storage_disk ?: config('filesystems.default', 's3');
        foreach ($paths as $index => $path) {
            $mimeType = $mimeTypes[$index] ?? $document->mime_type;
            if (! $path) {
                continue;
            }
            if (filter_var($path, FILTER_VALIDATE_URL) !== false) {
                $images[] = Image::fromUrl($path, $mimeType);
            } else {
                $images[] = Image::fromStoragePath($path, $disk);
            }
        }

        return $images;
    }

    protected function isImage(array $mimeTypes, array $paths, ?string $filename): bool
    {
        foreach ($mimeTypes as $mimeType) {
            if (is_string($mimeType) && str_starts_with($mimeType, 'image/')) {
                return true;
            }
        }

        foreach ($paths as $path) {
            if ($this->isImageExtension($path)) {
                return true;
            }
        }

        return $this->isImageExtension($filename);
    }

    protected function isImageExtension(?string $path): bool
    {
        if (! $path) {
            return false;
        }

        $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));

        if ($extension === '') {
            return false;
        }

        $imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'tiff', 'heic'];

        return in_array($extension, $imageExtensions, true);
    }

    protected function learningPackSchema(): string
    {
        return <<<'SCHEMA'
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
SCHEMA;
    }

    protected function normalizeDifficulty(array $payload): array
    {
        $payload = $this->normalizeItemContent($payload);

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

    protected function normalizeItemContent(array $payload): array
    {
        if (! isset($payload['items']) || ! is_array($payload['items'])) {
            return $payload;
        }

        foreach ($payload['items'] as $itemIndex => $item) {
            if (! is_array($item) || ! array_key_exists('content', $item)) {
                continue;
            }

            $content = $item['content'];

            if (is_array($content) && array_is_list($content)) {
                $payload['items'][$itemIndex]['content'] = ['items' => $content];
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
