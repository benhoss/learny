<?php

namespace App\Jobs;

use App\Models\Game;
use App\Models\LearningPack;
use App\Models\Document;
use App\Support\Documents\PipelineTelemetry;
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
        $this->onQueue('games');
    }

    public function handle(GameGeneratorInterface $generator, JsonSchemaValidator $validator): void
    {
        $pack = LearningPack::find($this->learningPackId);

        if (! $pack) {
            return;
        }

        $document = Document::find((string) $pack->document_id);
        if ($document) {
            PipelineTelemetry::transition($document, 'game_generation', 85);
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
                $validator->validate($payload, resource_path("schemas/game_{$type}.json"));

                Game::create([
                    'user_id' => (string) $pack->user_id,
                    'child_profile_id' => (string) $pack->child_profile_id,
                    'learning_pack_id' => (string) $pack->_id,
                    'type' => $type,
                    'schema_version' => 'v1',
                    'payload' => $payload,
                    'status' => 'ready',
                ]);

                if ($document) {
                    $readyTypes = is_array($document->ready_game_types ?? null) ? $document->ready_game_types : [];
                    if (! in_array($type, $readyTypes, true)) {
                        $readyTypes[] = $type;
                    }
                    $document->ready_game_types = array_values($readyTypes);

                    if ($document->first_playable_at === null) {
                        $document->first_playable_at = now();
                        $document->first_playable_game_type = $type;
                        $document->progress_hint = max((int) ($document->progress_hint ?? 0), 90);
                    }

                    $document->save();
                }
            } catch (Throwable $e) {
                if ($document) {
                    PipelineTelemetry::complete($document, 'failed', 'game_generation_failed');
                    $document->ocr_error = $e->getMessage();
                    $document->save();
                }
                throw $e;
            }
        }

        if ($document) {
            PipelineTelemetry::complete($document, 'ready', 'ready', 100);
            $document->processed_at = now();
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
