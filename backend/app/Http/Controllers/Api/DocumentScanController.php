<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Jobs\ProcessDocumentOcr;
use App\Jobs\QuickScanDocumentMetadata;
use App\Models\Document;
use App\Support\Documents\PipelineTelemetry;
use Illuminate\Contracts\Cache\LockTimeoutException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class DocumentScanController extends Controller
{
    use FindsOwnedChild;

    public function show(string $childId, string $documentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $document = Document::where('_id', $documentId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        return response()->json([
            'data' => [
                'document_id' => (string) $document->_id,
                'scan_status' => $document->scan_status,
                'topic' => $document->scan_topic_suggestion,
                'language' => $document->scan_language_suggestion,
                'confidence' => $document->scan_confidence,
                'alternatives' => $document->scan_alternatives ?? [],
                'model' => $document->scan_model,
                'validation_status' => $document->validation_status,
                'validated_topic' => $document->validated_topic,
                'validated_language' => $document->validated_language,
            ],
        ]);
    }

    public function confirm(Request $request, string $childId, string $documentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $data = $request->validate([
            'topic' => ['required', 'string', 'max:120'],
            'language' => ['required', 'string', 'max:32'],
        ]);

        try {
            return Cache::lock('documents:confirm-scan:'.$documentId, 5)->block(
                3,
                function () use ($child, $data, $documentId): JsonResponse {
                    $document = Document::where('_id', $documentId)
                        ->where('child_profile_id', (string) $child->_id)
                        ->firstOrFail();

                    // Idempotent: do not redispatch OCR for repeated confirmations.
                    if (($document->validation_status ?? null) === 'confirmed') {
                        return response()->json(['data' => $document], 200);
                    }

                    $document->subject = $data['topic'];
                    $document->language = $data['language'];
                    $document->validated_topic = $data['topic'];
                    $document->validated_language = $data['language'];
                    $document->validated_at = now();
                    $document->validation_status = 'confirmed';
                    $document->scan_status = 'ready';
                    PipelineTelemetry::transition($document, 'queued', 35, 'queued');
                    $document->save();

                    ProcessDocumentOcr::dispatch((string) $document->_id);

                    return response()->json(['data' => $document], 202);
                }
            );
        } catch (LockTimeoutException) {
            return response()->json([
                'message' => 'Document confirmation already in progress. Please retry.',
            ], 409);
        }
    }

    public function rescan(string $childId, string $documentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $document = Document::where('_id', $documentId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        if (! $this->canRescanDocument($document)) {
            return response()->json([
                'message' => 'Document cannot be rescanned in its current state.',
            ], 409);
        }

        $document->scan_status = 'queued';
        $document->validation_status = 'pending';
        $document->scan_topic_suggestion = null;
        $document->scan_language_suggestion = null;
        $document->scan_confidence = null;
        $document->scan_alternatives = [];
        $document->scan_model = null;
        $document->scan_completed_at = null;
        PipelineTelemetry::transition($document, 'quick_scan_queued', 10, 'queued');
        $document->save();

        QuickScanDocumentMetadata::dispatch((string) $document->_id);

        return response()->json(['data' => $document], 202);
    }

    private function canRescanDocument(Document $document): bool
    {
        if (($document->validation_status ?? null) === 'confirmed') {
            return false;
        }

        $stage = (string) ($document->pipeline_stage ?? '');
        if ($stage !== '') {
            return in_array($stage, ['awaiting_validation', 'quick_scan_failed'], true);
        }

        return in_array((string) ($document->scan_status ?? ''), ['ready', 'failed'], true);
    }
}
