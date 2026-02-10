<?php

namespace App\Services\Documents;

use App\Models\Document;

class QuickScanService
{
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

        return [
            'topic' => $topic,
            'language' => $language,
            'confidence' => (float) ($suggestion['confidence'] ?? 0.5),
            'alternatives' => is_array($alternatives) ? array_values($alternatives) : [],
            'model' => (string) config('prism.openrouter.fast_scan_model', 'heuristic-fast-v1'),
        ];
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

