<?php

namespace App\Jobs;

use App\Models\Document;
use App\Jobs\ExtractConceptsFromDocument;
use App\Services\Ocr\OcrClientInterface;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Throwable;

class ProcessDocumentOcr implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(private readonly string $documentId)
    {
    }

    public function handle(OcrClientInterface $ocrClient): void
    {
        $document = Document::find($this->documentId);

        if (! $document) {
            return;
        }

        $document->status = 'processing';
        $document->ocr_error = null;
        $document->save();

        if ($this->shouldSkipOcr($document->mime_type, $document->storage_path, $document->original_filename)) {
            $document->status = 'processed';
            $document->processed_at = now();
            $document->save();

            ExtractConceptsFromDocument::dispatch((string) $document->_id);

            return;
        }

        try {
            $document->extracted_text = $ocrClient->extractText(
                $document->storage_disk,
                $document->storage_path,
                $document->mime_type
            );
            $document->status = 'processed';
            $document->processed_at = now();
            $document->save();

            ExtractConceptsFromDocument::dispatch((string) $document->_id);
        } catch (Throwable $e) {
            $document->status = 'failed';
            $document->ocr_error = $e->getMessage();
            $document->save();

            throw $e;
        }
    }

    private function shouldSkipOcr(?string $mimeType, ?string $path, ?string $filename): bool
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
