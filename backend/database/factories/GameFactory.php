<?php

namespace Database\Factories;

use App\Models\Game;
use Illuminate\Database\Eloquent\Factories\Factory;

class GameFactory extends Factory
{
    protected $model = Game::class;

    public function definition(): array
    {
        return [
            'user_id' => null,
            'child_profile_id' => null,
            'learning_pack_id' => null,
            'type' => 'flashcards',
            'schema_version' => 'v1',
            'status' => 'ready',
            'payload' => [
                'cards' => [
                    ['front' => '2+2', 'back' => '4'],
                ],
            ],
        ];
    }
}
