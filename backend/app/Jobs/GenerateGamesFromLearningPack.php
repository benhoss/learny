<?php

namespace App\Jobs;

use App\Models\Game;
use App\Models\LearningPack;
use App\Models\Document;
use App\Services\Safety\GenerationSafetyGuard;
use App\Support\Ai\GenerationObservability;
use App\Support\Documents\PipelineTelemetry;
use App\Services\Generation\GameGeneratorInterface;
use App\Services\Schemas\JsonSchemaValidator;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Throwable;

class GenerateGamesFromLearningPack implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(private readonly string $learningPackId)
    {
        $this->onQueue('games');
    }

    public function handle(GameGeneratorInterface $generator, JsonSchemaValidator $validator, GenerationSafetyGuard $safetyGuard): void
    {
        $jobStart = microtime(true);
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

        try {
            foreach ($types as $type) {
                $run = GenerationObservability::startRun([
                    'feature_name' => 'game_generation_'.$type,
                    'actor_type' => 'system',
                    'actor_ref' => (string) $pack->user_id,
                    'child_profile_id' => (string) $pack->child_profile_id,
                    'document_id' => (string) $pack->document_id,
                    'provider' => 'openrouter',
                    'model_name' => (string) config('prism.openrouter.text_model', 'unknown'),
                    'model_version' => (string) config('prism.openrouter.text_model', 'unknown'),
                    'prompt_template_version' => 'v1',
                ]);

                try {
                    $payload = $generator->generate($pack, $type);
                    GenerationObservability::recordArtifact($run, 'normalized_json', $payload, 'game_'.$type, 'v1');

                    try {
                        $validator->validate($payload, resource_path("schemas/game_{$type}.json"));
                        GenerationObservability::recordGuardrail($run, 'output_schema_validation', 'v1', 'pass');
                    } catch (Throwable $schemaError) {
                        GenerationObservability::recordGuardrail($run, 'output_schema_validation', 'v1', 'fail', 70, ['schema_validation_failed'], ['message' => $schemaError->getMessage()]);
                        GenerationObservability::complete($run, 'blocked', 70, $schemaError->getMessage());
                        throw $schemaError;
                    }

                    $safetyResult = $safetyGuard->evaluate($payload);
                    GenerationObservability::recordGuardrail(
                        $run,
                        'child_safety_terms',
                        (string) config('learny.ai_guardrails.policy_version', 'v1'),
                        (string) $safetyResult['result'],
                        (int) ($safetyResult['risk_points'] ?? 0),
                        (array) ($safetyResult['reason_codes'] ?? []),
                        (array) ($safetyResult['details'] ?? [])
                    );

                    if (($safetyResult['result'] ?? 'pass') === 'fail') {
                        $message = 'Safety guardrail blocked game generation.';
                        GenerationObservability::complete($run, 'blocked', (int) ($safetyResult['risk_points'] ?? 80), $message);
                        throw new \RuntimeException($message);
                    }

                    Game::create([
                        'user_id' => (string) $pack->user_id,
                        'child_profile_id' => (string) $pack->child_profile_id,
                        'learning_pack_id' => (string) $pack->_id,
                        'type' => $type,
                        'schema_version' => 'v1',
                        'payload' => $payload,
                        'status' => 'ready',
                    ]);

                    GenerationObservability::complete($run, 'served');

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
                    if (($run->final_status ?? null) === 'processing') {
                        GenerationObservability::complete($run, 'error', 0, $e->getMessage());
                    }

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
        } finally {
            $durationMs = (int) round((microtime(true) - $jobStart) * 1000);
            if ($document) {
                PipelineTelemetry::recordRuntime($document, 'game_generation_runtime_ms', $durationMs);
                $document->save();
                Log::info('game_generation_runtime_ms', [
                    'document_id' => (string) $document->_id,
                    'duration_ms' => $durationMs,
                ]);
            }
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
