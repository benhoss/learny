<?php

namespace App\Jobs;

use App\Models\Game;
use App\Models\LearningPack;
use App\Models\Document;
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

        $document = Document::find((string) $pack->document_id);
        if ($document) {
            $document->pipeline_stage = 'game_generation';
            $document->stage_started_at = now();
            $document->stage_completed_at = null;
            $document->progress_hint = 85;
            $document->save();
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
        $types = $this->filterRequestedTypes($pack, $types);

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
                if ($document) {
                    $document->status = 'failed';
                    $document->pipeline_stage = 'game_generation_failed';
                    $document->stage_completed_at = now();
                    $document->ocr_error = $e->getMessage();
                    $document->save();
                }
                throw $e;
            }
        }

        if ($document) {
            $document->status = 'ready';
            $document->pipeline_stage = 'ready';
            $document->processed_at = now();
            $document->stage_completed_at = now();
            $document->progress_hint = 100;
            $document->save();
        }
    }

    private function filterRequestedTypes(LearningPack $pack, array $defaultTypes): array
    {
        $documentId = $pack->document_id;
        if (! $documentId) {
            return $defaultTypes;
        }

        $document = Document::find($documentId);
        if (! $document) {
            return $defaultTypes;
        }

        $requested = $document->requested_game_types;
        if (! is_array($requested) || $requested === []) {
            return $defaultTypes;
        }

        $normalized = array_values(array_unique(array_filter($requested, 'is_string')));
        $allowed = array_values(array_intersect($defaultTypes, $normalized));

        return $allowed !== [] ? $allowed : $defaultTypes;
    }
}
