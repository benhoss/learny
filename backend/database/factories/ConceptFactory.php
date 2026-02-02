<?php

namespace Database\Factories;

use App\Models\Concept;
use Illuminate\Database\Eloquent\Factories\Factory;

class ConceptFactory extends Factory
{
    protected $model = Concept::class;

    public function definition(): array
    {
        return [
            'child_profile_id' => null,
            'document_id' => null,
            'concept_key' => 'fractions.addition.basic',
            'concept_label' => 'Adding fractions',
            'difficulty' => 0.6,
        ];
    }
}
