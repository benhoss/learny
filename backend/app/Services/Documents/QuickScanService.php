<?php

namespace App\Services\Documents;

use App\Concerns\RetriesLlmCalls;
use App\Models\Document;
use Prism\Prism\Enums\Provider;
use Prism\Prism\Facades\Prism;
use Prism\Prism\ValueObjects\Media\Image;
use Illuminate\Support\Facades\Log;

class QuickScanService
{
    use RetriesLlmCalls;

    public function __construct(private readonly MetadataSuggestionService $metadataSuggestion)
    {
    }

    /**
     * @return array{
     *   topic: string,
     *   language: string,
     *   confidence: float,
     *   alternatives: array<int, string>,
     *   model: string
     * }
     */
    public function scan(Document $document): array
    {
        $imageContent = $this->imageContentForDocument($document);
        $hasImage = $imageContent !== [];
        $hasOpenRouter = (bool) config('prism.providers.openrouter.api_key');
        if ($imageContent !== [] && config('prism.providers.openrouter.api_key')) {
            $vision = $this->scanWithVision($document, $imageContent);
            if (is_array($vision)) {
                Log::info('quick_scan.vision', [
                    'document_id' => (string) $document->_id,
                    'topic' => $vision['topic'],
                    'language' => $vision['language'],
                    'confidence' => $vision['confidence'],
                    'model' => $vision['model'],
                ]);
                return $vision;
            }
            Log::warning('quick_scan.vision_failed', [
                'document_id' => (string) $document->_id,
                'has_image' => $hasImage,
                'has_openrouter' => $hasOpenRouter,
            ]);
        }

        $suggestion = $this->metadataSuggestion->suggest([
            'filename' => (string) ($document->original_filename ?? ''),
            'context_text' => trim(implode(' ', array_filter([
                $document->subject,
                $document->learning_goal,
                $document->context_text,
            ]))),
            'language_hint' => (string) ($document->language ?? ''),
        ]);

        $topic = $this->normalizeTopic($suggestion['subject'] ?? null, $document);
        $language = $this->normalizeLanguage($suggestion['language'] ?? null, $document);
        $alternatives = $suggestion['alternatives'] ?? [];

        $result = [
            'topic' => $topic,
            'language' => $language,
            'confidence' => (float) ($suggestion['confidence'] ?? 0.5),
            'alternatives' => is_array($alternatives) ? array_values($alternatives) : [],
            'model' => (string) config('prism.openrouter.fast_scan_model', 'heuristic-fast-v1'),
        ];
        Log::info('quick_scan.heuristic', [
            'document_id' => (string) $document->_id,
            'topic' => $result['topic'],
            'language' => $result['language'],
            'confidence' => $result['confidence'],
            'model' => $result['model'],
            'has_image' => $hasImage,
            'has_openrouter' => $hasOpenRouter,
        ]);

        return $result;
    }

    /**
     * @param  array<int, Image>  $imageContent
     * @return array{
     *   topic: string,
     *   language: string,
     *   confidence: float,
     *   alternatives: array<int, string>,
     *   model: string
     * }|null
     */
    private function scanWithVision(Document $document, array $imageContent): ?array
    {
        $model = (string) config('prism.openrouter.fast_scan_model', 'google/gemini-2.0-flash-lite-001');
        $prompt = $this->buildVisionPrompt($document);

        $response = $this->callWithRetry(function () use ($model, $prompt, $imageContent) {
            return Prism::text()
                ->using(Provider::OpenRouter, $model)
                ->withSystemPrompt('Return only valid JSON. Do not include any other text.')
                ->withPrompt($prompt, $imageContent)
                ->withMaxTokens(300)
                ->usingTemperature(0.2)
                ->asText();
        });

        $decoded = json_decode($response->text, true);
        if (! is_array($decoded)) {
            $decoded = $this->extractJson($response->text);
        }

        if (! is_array($decoded)) {
            return null;
        }

        $topic = $this->normalizeTopic($decoded['topic'] ?? null, $document);
        $language = $this->normalizeLanguage($decoded['language'] ?? null, $document);
        $alternatives = $decoded['alternatives'] ?? [];
        $confidence = (float) ($decoded['confidence'] ?? 0.5);

        return [
            'topic' => $topic,
            'language' => $language,
            'confidence' => max(0.0, min(1.0, $confidence)),
            'alternatives' => is_array($alternatives) ? array_values($alternatives) : [],
            'model' => $model,
        ];
    }

    private function buildVisionPrompt(Document $document): string
    {
        $context = trim(implode(' ', array_filter([
            $document->original_filename,
            $document->subject,
            $document->learning_goal,
            $document->context_text,
        ])));

        $languageHint = (string) ($document->language ?? '');

        return <<<PROMPT
You are classifying a school document image.
Return JSON only, no markdown:
{
  "topic": string,        // one of: Math, Science, History, Geography, Language, General
  "language": string,     // English, French, Spanish, Dutch, or General if unknown
  "confidence": number,   // 0.0 to 1.0
  "alternatives": [string]
}

Rules:
- Prefer the document's actual language over English if the text is clearly non-English.
- If unsure, set topic "General" and confidence <= 0.5.
- Use the image content as the main source of truth.

Context text (may be empty): {$context}
Language hint (may be empty): {$languageHint}
PROMPT;
    }

    /**
     * @return array<int, Image>
     */
    private function imageContentForDocument(Document $document): array
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

    private function isImage(array $mimeTypes, array $paths, ?string $filename): bool
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

    private function isImageExtension(?string $path): bool
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

    private function normalizeTopic(mixed $topic, Document $document): string
    {
        $candidate = trim((string) $topic);
        if ($candidate !== '') {
            return $candidate;
        }

        $fromDocument = trim((string) ($document->subject ?? ''));
        if ($fromDocument !== '') {
            return $fromDocument;
        }

        return 'General';
    }

    private function normalizeLanguage(mixed $language, Document $document): string
    {
        $candidate = trim((string) $language);
        if ($candidate !== '') {
            return $candidate;
        }

        $fromDocument = trim((string) ($document->language ?? ''));
        if ($fromDocument !== '') {
            return $fromDocument;
        }

        return 'English';
    }
}
