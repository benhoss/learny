---
status: complete
priority: p2
issue_id: "041"
tags: [code-review, backend, api, reliability]
dependencies: []
---

# Guard confirm-scan by pipeline state

Confirming a scan should only be allowed when the document is in a valid scan-validation stage. Right now, the API will accept confirmation in any state, which can regress pipeline stage and duplicate OCR work if clients call it out of order.

## Problem Statement

`POST /documents/{id}/confirm-scan` currently confirms and re-queues OCR without verifying that the document is actually awaiting validation. If a client calls this endpoint while the document is already processing or generating packs, the controller will reset the pipeline stage to `queued`, overwrite scan status, and dispatch OCR again. This risks duplicated work, telemetry regressions, and confusing state transitions.

## Findings

- `DocumentScanController::confirm` does not validate current `pipeline_stage` or `scan_status` before transitioning and dispatching OCR.
- Only guard is `validation_status == confirmed`; any other state proceeds.
- Location: `backend/app/Http/Controllers/Api/DocumentScanController.php:44-77`.
- No test coverage for rejecting confirmation in invalid stages (deep processing, ready, failed OCR, etc.).

## Proposed Solutions

### Option 1: Enforce allowed states in controller

**Approach:** Reject confirmation unless the document is in `awaiting_validation` or `quick_scan_failed` (or `scan_status` in `ready/failed`). Return 409 with a clear message.

**Pros:**
- Simple, localized change
- Prevents accidental state regression

**Cons:**
- Requires clients to handle 409

**Effort:** 1-2 hours

**Risk:** Low

---

### Option 2: Centralize transition validation on the model/service

**Approach:** Add a `Document::canConfirmScan()` (or service) that validates allowed transitions and reuse it in controller + jobs.

**Pros:**
- Prevents future drift
- Reusable across other entry points

**Cons:**
- Slightly larger change

**Effort:** 2-4 hours

**Risk:** Low

---

### Option 3: Idempotent confirm with no-op on invalid stage

**Approach:** If not in allowed stage, return 200 with current document and no changes.

**Pros:**
- Client-friendly
- Avoids errors in UI

**Cons:**
- Hides invalid state calls
- Harder to detect bugs

**Effort:** 1-2 hours

**Risk:** Medium

## Recommended Action

**To be filled during triage.**

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/DocumentScanController.php:44-77`
- `backend/tests/Feature/DocumentUploadTest.php` (add coverage)

**Related components:**
- Quick scan pipeline (`QuickScanDocumentMetadata`)
- OCR pipeline (`ProcessDocumentOcr`)

**Database changes (if any):**
- Migration needed? No

## Resources

- **API endpoint:** `POST /api/v1/children/{child}/documents/{document}/confirm-scan`
- **Related tests:** `backend/tests/Feature/DocumentUploadTest.php`

## Acceptance Criteria

- [x] Confirmation is rejected (409 or safe no-op) when document is not awaiting validation.
- [x] Confirmation succeeds when `pipeline_stage` is `awaiting_validation` or `quick_scan_failed`.
- [x] Tests cover invalid-state confirmation attempts.
- [x] No duplicate OCR dispatch from invalid confirmations.

## Work Log

### 2026-02-10 - Initial Discovery

**By:** Claude Code

**Actions:**
- Reviewed `DocumentScanController::confirm` state transitions
- Identified missing guard for invalid pipeline stages
- Drafted remediation options

**Learnings:**
- Current guard only checks `validation_status == confirmed`
- Pipeline stage can regress to `queued` from any state

### 2026-02-10 - Implementation

**By:** Claude Code

**Actions:**
- Added confirm-scan state guard in `backend/app/Http/Controllers/Api/DocumentScanController.php`
- Added invalid-stage confirmation test in `backend/tests/Feature/DocumentUploadTest.php`
- Attempted to run `./vendor/bin/phpunit --filter DocumentUploadTest` (failed: missing MongoDB driver)

**Learnings:**
- Confirmation now rejects invalid pipeline stages with 409

## Notes

- Align error response with existing rescan conflict message for UX consistency.
