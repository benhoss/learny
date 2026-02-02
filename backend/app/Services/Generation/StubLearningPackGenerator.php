<?php

namespace App\Services\Generation;

use App\Models\Document;

class StubLearningPackGenerator implements LearningPackGeneratorInterface
{
    public function generate(Document $document, array $concepts): array
    {
        $concept = $concepts[0] ?? ['key' => 'general', 'label' => 'General'];

        return [
            'objective' => 'Understand the key ideas in this lesson.',
            'summary' => $document->extracted_text ? substr($document->extracted_text, 0, 120) : '',
            'concepts' => [
                [
                    'key' => $concept['concept_key'] ?? $concept['key'] ?? 'general',
                    'label' => $concept['concept_label'] ?? $concept['label'] ?? 'General',
                    'difficulty' => (float) ($concept['difficulty'] ?? 0.5),
                ],
            ],
            'items' => [
                [
                    'type' => 'flashcards',
                    'content' => [
                        'cards' => [
                            [
                                'front' => 'What is the main idea?',
                                'back' => $concept['concept_label'] ?? $concept['label'] ?? 'General',
                            ],
                        ],
                    ],
                ],
            ],
        ];
    }
}
