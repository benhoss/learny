<?php

namespace Database\Factories;

use App\Models\MasteryProfile;
use Illuminate\Database\Eloquent\Factories\Factory;

class MasteryProfileFactory extends Factory
{
    protected $model = MasteryProfile::class;

    public function definition(): array
    {
        return [
            'child_profile_id' => null,
            'concept_key' => 'fractions.addition.basic',
            'concept_label' => 'Adding fractions',
            'mastery_level' => 0.5,
            'total_attempts' => 10,
            'correct_attempts' => 6,
            'last_attempt_at' => now(),
        ];
    }
}
