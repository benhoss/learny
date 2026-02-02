<?php

namespace Database\Factories;

use App\Models\ChildProfile;
use Illuminate\Database\Eloquent\Factories\Factory;

class ChildProfileFactory extends Factory
{
    protected $model = ChildProfile::class;

    public function definition(): array
    {
        return [
            'user_id' => null,
            'name' => $this->faker->firstName(),
            'grade_level' => $this->faker->randomElement(['5th', '6th', '7th']),
            'birth_year' => $this->faker->numberBetween(2010, 2015),
            'notes' => $this->faker->sentence(),
        ];
    }
}
