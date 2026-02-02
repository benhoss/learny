<?php

namespace App\Jobs;

use App\Models\Concept;
use App\Models\Document;
use App\Jobs\GenerateLearningPackFromDocument;
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
    }

    public function handle(ConceptExtractorInterface $extractor): void
    {
        $document = Document::find($this->documentId);

        if (! $document) {
            return;
        }

        $hasText = filled($document->extracted_text);
        $isImage = $this->isImage(
            $document->mime_type,
            $document->storage_path,
            $document->original_filename
        );

        if (! $hasText && ! $isImage) {
            return;
        }

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

            GenerateLearningPackFromDocument::dispatch((string) $document->_id);
        } catch (Throwable $e) {
            throw $e;
        }
    }

    private function isImage(?string $mimeType, ?string $path, ?string $filename): bool
    {
        if (is_string($mimeType) && str_starts_with($mimeType, 'image/')) {
            return true;
        }

        $extension = $this->extensionFromPath($path) ?: $this->extensionFromPath($filename);
        if (! $extension) {
            return false;
        }

        $imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'tiff', 'heic'];

        return in_array($extension, $imageExtensions, true);
    }

    private function extensionFromPath(?string $path): ?string
    {
        if (! $path) {
            return null;
        }

        $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));

        return $extension !== '' ? $extension : null;
    }
}
