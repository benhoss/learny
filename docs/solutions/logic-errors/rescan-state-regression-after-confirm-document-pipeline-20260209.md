---
module: Document Pipeline
date: 2026-02-09
problem_type: logic_error
component: rails_controller
symptoms:
  - "POST /api/v1/children/{child}/documents/{document}/rescan returned 202 for already-confirmed documents"
  - "Rescan reset validation_status to pending and moved pipeline_stage back to quick_scan_queued"
  - "Confirmed/deep-stage documents could be regressed and quick-scan job redispatched"
root_cause: missing_validation
resolution_type: code_fix
severity: critical
tags: [document-pipeline, state-machine, rescan, idempotency, regression-guard]
---

# Troubleshooting: Rescan State Regression After Confirmation

## Problem
The `rescan` endpoint accepted requests after scan confirmation or during deep-generation stages. This allowed state regression and reopened documents that should have remained forward-only in the pipeline.

## Environment
- Module: Document Pipeline
- Framework: Laravel backend API
- Affected Component: `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php`
- Date: 2026-02-09

## Symptoms
- Confirmed documents could still be rescanned.
- `validation_status` was reset from `confirmed` to `pending`.
- `pipeline_stage` was reset to `quick_scan_queued` and `QuickScanDocumentMetadata` was dispatched again.
- Deep-stage documents (for example `learning_pack_generation`) could be rewound to scan stage.

## What Didn't Work

**Attempted Solution 1:** Hardened `confirm-scan` with locking and idempotency.
- **Why it failed:** It protected confirmation races but did not constrain `rescan`, so state regression remained possible through a different endpoint.

**Attempted Solution 2:** Added quick-scan job mutation guards.
- **Why it failed:** Job-side guards prevented some stale writes, but `rescan` still initiated an invalid backward transition before job execution.

## Solution

Added an explicit state guard in `rescan()` to reject invalid pipeline states with `409 Conflict`, and kept reset behavior only for scan-validation states.

**Code changes**:
```php
// Before (broken):
public function rescan(string $childId, string $documentId): JsonResponse
{
    // ...
    $document->scan_status = 'queued';
    $document->validation_status = 'pending';
    PipelineTelemetry::transition($document, 'quick_scan_queued', 10, 'queued');
    $document->save();
    QuickScanDocumentMetadata::dispatch((string) $document->_id);
    return response()->json(['data' => $document], 202);
}

// After (fixed):
if (! $this->canRescanDocument($document)) {
    return response()->json([
        'message' => 'Document cannot be rescanned in its current state.',
    ], 409);
}
```

Additional guard method:
```php
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
```

**Tests added**:
- `test_rescan_rejects_confirmed_document_and_does_not_dispatch_job`
- `test_rescan_rejects_document_already_in_deep_processing_stage`

## Why This Works
The root issue was missing state-transition validation on the `rescan` entrypoint. The new guard enforces state-machine invariants by allowing rescan only in scan-validation stages and rejecting backward transitions from confirmed or deep-processing stages. This blocks destructive rewinds and prevents duplicate quick-scan dispatches from invalid states.

## Prevention
- Treat all pipeline endpoints as state transitions and enforce explicit allowed-state checks.
- Add endpoint-level tests for both allowed and rejected transitions.
- Keep job-level guards and endpoint guards together; endpoint guards stop invalid transitions early, job guards protect against stale concurrency edges.
- Include regression tests whenever a state-locking/idempotency fix is added to one endpoint, then audit sibling endpoints for the same invariant.

## Related Issues
- Review todo: `/Users/benoit/Documents/Projects/P3rform/learny/todos/040-complete-p1-rescan-allows-state-regression-after-confirm.md`
- Related hardening:
  - `/Users/benoit/Documents/Projects/P3rform/learny/todos/036-complete-p1-quick-scan-overwrites-confirmed-validation.md`
  - `/Users/benoit/Documents/Projects/P3rform/learny/todos/037-complete-p1-confirm-scan-idempotency-not-atomic.md`
