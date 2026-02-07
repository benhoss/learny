<?php

namespace App\Jobs;

use App\Models\Concept;
use App\Models\Document;
use App\Jobs\GenerateLearningPackFromDocument;
use App\Support\Documents\PipelineTelemetry;
use App\Services\Concepts\ConceptExtractorInterface;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Throwable;

class ExtractConceptsFromDocument implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(private readonly string $documentId)
    {
        $this->onQueue('concepts');
    }

    public function handle(ConceptExtractorInterface $extractor): void
    {
        $document = Document::find($this->documentId);

        if (! $document) {
            return;
        }

        $hasText = filled($document->extracted_text);
        $isImage = $this->isImage($document);

        if (! $hasText && ! $isImage) {
            return;
        }

        PipelineTelemetry::transition($document, 'concept_extraction', 45);
        $document->save();

        try {
            if ($hasText) {
                $concepts = $extractor->extract($document->extracted_text);
                $childId = (string) $document->child_profile_id;

                foreach ($concepts as $concept) {
                    Concept::updateOrCreate(
                        [
                            'child_profile_id' => $childId,
                            'document_id' => (string) $document->_id,
                            'concept_key' => $concept['key'],
                        ],
                        [
                            'concept_label' => $concept['label'],
                            'difficulty' => $concept['difficulty'],
                        ]
                    );
                }
            }

            PipelineTelemetry::transition($document, 'learning_pack_queued', 60);
            $document->save();

            GenerateLearningPackFromDocument::dispatch((string) $document->_id);
        } catch (Throwable $e) {
            PipelineTelemetry::complete($document, 'failed', 'concept_extraction_failed');
            $document->ocr_error = $e->getMessage();
            $document->save();
            throw $e;
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
