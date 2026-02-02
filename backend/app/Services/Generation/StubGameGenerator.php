<?php

namespace App\Services\Generation;

use App\Models\LearningPack;

class StubGameGenerator implements GameGeneratorInterface
{
    public function generate(LearningPack $pack, string $type): array
    {
        return match ($type) {
            'flashcards' => [
                'cards' => [
                    ['front' => '2+2', 'back' => '4'],
                ],
            ],
            'quiz' => [
                'questions' => [
                    [
                        'prompt' => '2 + 2 = ?',
                        'choices' => ['3', '4'],
                        'answer_index' => 1,
                    ],
                ],
            ],
            'matching' => [
                'pairs' => [
                    ['left' => '1/2', 'right' => '0.5'],
                ],
            ],
            default => [],
        };
    }
}
