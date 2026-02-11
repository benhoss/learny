<?php

namespace App\Jobs;

use App\Models\Concept;
use App\Models\Document;
use App\Models\LearningPack;
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
        JsonSchemaValidator $validator
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

        try {
            PipelineTelemetry::transition($document, 'learning_pack_generation', 65);
            $document->save();

            $concepts = Concept::where('document_id', (string) $document->_id)->get()->toArray();

            try {
                $content = $generator->generate($document, $concepts);
                $validator->validate($content, resource_path('schemas/learning_pack.json'));

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
            } catch (Throwable $e) {
                PipelineTelemetry::complete($document, 'failed', 'learning_pack_failed');
                $document->ocr_error = $e->getMessage();
                $document->save();
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
