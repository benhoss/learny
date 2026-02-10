<?php

namespace App\Jobs;

use App\Models\Document;
use App\Services\Documents\QuickScanService;
use App\Support\Documents\PipelineTelemetry;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Throwable;

class QuickScanDocumentMetadata implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(private readonly string $documentId)
    {
        $this->onQueue('scan');
    }

    public function handle(QuickScanService $service): void
    {
        $document = Document::find($this->documentId);

        if (! $document || $this->shouldAbortScanMutation($document)) {
            return;
        }

        PipelineTelemetry::transition($document, 'quick_scan_processing', 20, 'processing');
        $document->scan_status = 'processing';
        $document->save();

        try {
            $scan = $service->scan($document);

            $document = Document::find($this->documentId);
            if (! $document || $this->shouldAbortScanMutation($document)) {
                return;
            }

            $document->scan_status = 'ready';
            $document->scan_topic_suggestion = $scan['topic'];
            $document->scan_language_suggestion = $scan['language'];
            $document->scan_confidence = $scan['confidence'];
            $document->scan_alternatives = $scan['alternatives'];
            $document->scan_model = $scan['model'];
            $document->scan_completed_at = now();
            $document->validation_status = 'pending';

            PipelineTelemetry::transition($document, 'awaiting_validation', 30, 'queued');
            $document->save();
        } catch (Throwable $e) {
            $document = Document::find($this->documentId);
            if (! $document || $this->shouldAbortScanMutation($document)) {
                return;
            }

            $document->scan_status = 'failed';
            $document->validation_status = 'pending';
            PipelineTelemetry::complete($document, 'failed', 'quick_scan_failed');
            $document->ocr_error = $e->getMessage();
            $document->save();
            throw $e;
        }
    }

    private function shouldAbortScanMutation(Document $document): bool
    {
        if (($document->validation_status ?? null) === 'confirmed') {
            return true;
        }

        $stage = (string) ($document->pipeline_stage ?? '');
        if ($stage === '') {
            return false;
        }

        return ! in_array($stage, ['quick_scan_queued', 'quick_scan_processing', 'quick_scan_failed'], true);
    }
}
