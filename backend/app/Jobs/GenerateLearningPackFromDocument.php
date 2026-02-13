<?php

namespace App\Jobs;

use App\Models\Concept;
use App\Models\Document;
use App\Models\LearningPack;
use App\Services\Safety\GenerationSafetyGuard;
use App\Support\Ai\GenerationObservability;
use App\Support\Documents\PipelineTelemetry;
use App\Services\Generation\LearningPackGeneratorInterface;
use App\Services\Schemas\JsonSchemaValidator;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Throwable;

class GenerateLearningPackFromDocument implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(private readonly string $documentId)
    {
        $this->onQueue('pack');
    }

    public function handle(
        LearningPackGeneratorInterface $generator,
        JsonSchemaValidator $validator,
        GenerationSafetyGuard $safetyGuard
    ): void {
        $jobStart = microtime(true);
        $document = Document::find($this->documentId);

        if (! $document) {
            return;
        }

        $hasText = filled($document->extracted_text);
        $isImage = $this->isImage($document);

        if (! $hasText && ! $isImage) {
            return;
        }

        $run = GenerationObservability::startRunSafely([
            'feature_name' => 'learning_pack_generation',
            'actor_type' => 'system',
            'actor_ref' => (string) $document->user_id,
            'child_profile_id' => (string) $document->child_profile_id,
            'document_id' => (string) $document->_id,
            'provider' => 'openrouter',
            'model_name' => (string) config('prism.openrouter.text_model', 'unknown'),
            'model_version' => (string) config('prism.openrouter.text_model', 'unknown'),
            'prompt_template_version' => 'v1',
        ], [
            'document_id' => (string) $document->_id,
            'job' => self::class,
        ]);

        try {
            PipelineTelemetry::transition($document, 'learning_pack_generation', 65);
            $document->save();

            $concepts = Concept::where('document_id', (string) $document->_id)->get()->toArray();

            try {
                $content = $generator->generate($document, $concepts);
                GenerationObservability::recordArtifactSafely($run, 'normalized_json', $content, 'learning_pack', 'v1', [
                    'document_id' => (string) $document->_id,
                ]);

                try {
                    $validator->validate($content, resource_path('schemas/learning_pack.json'));
                    GenerationObservability::recordGuardrailSafely($run, 'output_schema_validation', 'v1', 'pass', 0, [], [], [
                        'document_id' => (string) $document->_id,
                    ]);
                } catch (Throwable $schemaError) {
                    GenerationObservability::recordGuardrailSafely($run, 'output_schema_validation', 'v1', 'fail', 70, ['schema_validation_failed'], ['message' => $schemaError->getMessage()], [
                        'document_id' => (string) $document->_id,
                    ]);
                    GenerationObservability::completeSafely($run, 'blocked', 70, $schemaError->getMessage(), [
                        'document_id' => (string) $document->_id,
                    ]);
                    throw $schemaError;
                }

                $safetyResult = $safetyGuard->evaluate($content);
                GenerationObservability::recordGuardrailSafely(
                    $run,
                    'child_safety_terms',
                    (string) config('learny.ai_guardrails.policy_version', 'v1'),
                    (string) $safetyResult['result'],
                    (int) ($safetyResult['risk_points'] ?? 0),
                    (array) ($safetyResult['reason_codes'] ?? []),
                    (array) ($safetyResult['details'] ?? []),
                    [
                        'document_id' => (string) $document->_id,
                    ]
                );

                if (($safetyResult['result'] ?? 'pass') === 'fail') {
                    $message = 'Safety guardrail blocked learning pack generation.';
                    GenerationObservability::completeSafely($run, 'blocked', (int) ($safetyResult['risk_points'] ?? 80), $message, [
                        'document_id' => (string) $document->_id,
                    ]);
                    throw new \RuntimeException($message);
                }

                $pack = LearningPack::create([
                    'user_id' => (string) $document->user_id,
                    'child_profile_id' => (string) $document->child_profile_id,
                    'document_id' => (string) $document->_id,
                    'title' => $document->original_filename ?? 'Learning Pack',
                    'summary' => $content['summary'] ?? null,
                    'status' => 'ready',
                    'schema_version' => 'v1',
                    'content' => $content,
                    'subject' => $document->subject,
                    'topic' => $document->topic ?? $document->validated_topic,
                    'grade_level' => $document->grade_level,
                    'language' => $document->language ?? $document->validated_language,
                    'document_type' => $document->document_type,
                    'source' => $document->source,
                    'tags' => $document->tags ?? [],
                    'collections' => $document->collections ?? [],
                ]);

                PipelineTelemetry::transition($document, 'game_generation_queued', 80);
                $document->save();

                GenerateGamesFromLearningPack::dispatch((string) $pack->_id);
                GenerationObservability::completeSafely($run, 'served', 0, null, [
                    'document_id' => (string) $document->_id,
                ]);
            } catch (Throwable $e) {
                PipelineTelemetry::complete($document, 'failed', 'learning_pack_failed');
                $document->ocr_error = $e->getMessage();
                $document->save();
                if ($run && ($run->final_status ?? null) === 'processing') {
                    GenerationObservability::completeSafely($run, 'error', 0, $e->getMessage(), [
                        'document_id' => (string) $document->_id,
                    ]);
                }
                throw $e;
            }
        } finally {
            $durationMs = (int) round((microtime(true) - $jobStart) * 1000);
            $document = Document::find($this->documentId);
            if ($document) {
                PipelineTelemetry::recordRuntime($document, 'learning_pack_runtime_ms', $durationMs);
                $document->save();
                Log::info('learning_pack_runtime_ms', [
                    'document_id' => (string) $document->_id,
                    'duration_ms' => $durationMs,
                ]);
            }
        }
    }

    private function isImage(Document $document): bool
    {
        $mimeTypes = array_filter(array_merge(
            [$document->mime_type],
            is_array($document->mime_types ?? null) ? $document->mime_types : []
        ));
        foreach ($mimeTypes as $mimeType) {
            if (is_string($mimeType) && str_starts_with($mimeType, 'image/')) {
                return true;
            }
        }

        $paths = array_filter(array_merge(
            [$document->storage_path],
            is_array($document->storage_paths ?? null) ? $document->storage_paths : []
        ));
        foreach ($paths as $path) {
            if ($this->isImageExtension($path)) {
                return true;
            }
        }

        return $this->isImageExtension($document->original_filename);
    }

    private function isImageExtension(?string $path): bool
    {
        if (! $path) {
            return false;
        }

        $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));
        if ($extension === '') {
            return false;
        }

        $imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'tiff', 'heic'];

        return in_array($extension, $imageExtensions, true);
    }
}
