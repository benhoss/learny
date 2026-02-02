<?php

namespace App\Jobs;

use App\Models\Game;
use App\Models\LearningPack;
use App\Services\Generation\GameGeneratorInterface;
use App\Services\Schemas\JsonSchemaValidator;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Throwable;

class GenerateGamesFromLearningPack implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(private readonly string $learningPackId)
    {
    }

    public function handle(GameGeneratorInterface $generator, JsonSchemaValidator $validator): void
    {
        $pack = LearningPack::find($this->learningPackId);

        if (! $pack) {
            return;
        }

        $types = [
            'flashcards',
            'quiz',
            'matching',
            'true_false',
            'fill_blank',
            'ordering',
            'multiple_select',
            'short_answer',
        ];

        foreach ($types as $type) {
            try {
                $payload = $generator->generate($pack, $type);
                $validator->validate($payload, storage_path("app/schemas/game_{$type}.json"));

                Game::create([
                    'user_id' => (string) $pack->user_id,
                    'child_profile_id' => (string) $pack->child_profile_id,
                    'learning_pack_id' => (string) $pack->_id,
                    'type' => $type,
                    'schema_version' => 'v1',
                    'payload' => $payload,
                    'status' => 'ready',
                ]);
            } catch (Throwable $e) {
                throw $e;
            }
        }
    }
}
