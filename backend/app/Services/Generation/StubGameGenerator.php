<?php

namespace App\Services\Generation;

use App\Models\LearningPack;

class StubGameGenerator implements GameGeneratorInterface
{
    public function generate(LearningPack $pack, string $type): array
    {
        return match ($type) {
            'flashcards' => [
                'title' => 'Flashcards',
                'cards' => [
                    ['front' => '2+2', 'back' => '4'],
                ],
            ],
            'quiz' => [
                'title' => 'Quiz',
                'questions' => [
                    [
                        'prompt' => '2 + 2 = ?',
                        'choices' => ['3', '4'],
                        'answer_index' => 1,
                    ],
                ],
            ],
            'matching' => [
                'title' => 'Matching',
                'pairs' => [
                    ['left' => '1/2', 'right' => '0.5'],
                ],
            ],
            'true_false' => [
                'title' => 'True/False',
                'questions' => [
                    [
                        'statement' => 'A triangle has three sides.',
                        'answer' => true,
                    ],
                ],
            ],
            'fill_blank' => [
                'title' => 'Fill in the Blank',
                'questions' => [
                    [
                        'prompt' => '2 + __ = 4',
                        'answer' => '2',
                    ],
                ],
            ],
            'ordering' => [
                'title' => 'Ordering',
                'items' => [
                    [
                        'prompt' => 'Order numbers from smallest to largest.',
                        'sequence' => ['1', '2', '3'],
                    ],
                    [
                        'prompt' => 'Order letters alphabetically.',
                        'sequence' => ['a', 'b', 'c'],
                    ],
                ],
            ],
            'multiple_select' => [
                'title' => 'Multiple Select',
                'questions' => [
                    [
                        'prompt' => 'Select even numbers.',
                        'choices' => ['1', '2', '4'],
                        'answer_indices' => [1, 2],
                    ],
                ],
            ],
            'short_answer' => [
                'title' => 'Short Answer',
                'questions' => [
                    [
                        'prompt' => 'What is 5 + 5?',
                        'answer' => '10',
                    ],
                ],
            ],
            default => [
                'title' => 'Quiz',
                'questions' => [
                    [
                        'prompt' => '2 + 2 = ?',
                        'choices' => ['3', '4'],
                        'answer_index' => 1,
                    ],
                ],
            ],
        };
    }
}
