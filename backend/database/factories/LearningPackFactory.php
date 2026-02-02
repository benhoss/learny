<?php

namespace Database\Factories;

use App\Models\LearningPack;
use Illuminate\Database\Eloquent\Factories\Factory;

class LearningPackFactory extends Factory
{
    protected $model = LearningPack::class;

    public function definition(): array
    {
        return [
            'user_id' => null,
            'child_profile_id' => null,
            'document_id' => null,
            'title' => 'Fractions Pack',
            'summary' => 'Practice basic fractions.',
            'status' => 'ready',
            'schema_version' => 'v1',
            'content' => [
                'objective' => 'Understand adding fractions',
                'concepts' => [
                    ['key' => 'fractions.addition', 'label' => 'Adding fractions', 'difficulty' => 0.5],
                ],
                'items' => [
                    ['type' => 'flashcards', 'content' => ['cards' => [['front' => '1/2 + 1/4', 'back' => '3/4']]]],
                ],
            ],
        ];
    }
}
