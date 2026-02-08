<?php

namespace Database\Factories;

use App\Models\SchoolAssessment;
use Illuminate\Database\Eloquent\Factories\Factory;

class SchoolAssessmentFactory extends Factory
{
    protected $model = SchoolAssessment::class;

    public function definition(): array
    {
        $maxScore = $this->faker->randomElement([10, 20, 50, 100]);

        return [
            'child_profile_id' => null,
            'subject' => $this->faker->randomElement(['Math', 'French', 'Science', 'History', 'English']),
            'assessment_type' => $this->faker->randomElement(['weekly_test', 'quiz', 'exam', 'dictation']),
            'score' => $this->faker->numberBetween(0, $maxScore),
            'max_score' => $maxScore,
            'assessed_at' => $this->faker->dateTimeBetween('-6 months', 'now'),
            'source' => 'manual',
        ];
    }
}
