---
status: complete
priority: p1
issue_id: "040"
tags: [code-review, backend, data-integrity, state-machine]
dependencies: []
---

# Rescan Endpoint Allows State Regression After Confirmation

## Problem Statement

The `rescan` endpoint can be called after a document is already confirmed and/or has entered deep-generation stages. It forcibly resets scan and validation fields and transitions back to `quick_scan_queued`, which can regress pipeline state and conflict with OCR/pack/game jobs.

## Findings

- `rescan()` currently has no state guard.
- It always performs:
  - `validation_status = 'pending'`
  - `scan_*` reset
  - stage transition to `quick_scan_queued`
- Evidence:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php:95`
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php:103`
- This can reopen documents that should be immutable after confirmation and introduce inconsistent concurrent job behavior.

## Proposed Solutions

### Option 1: Guard Rescan By Pipeline/Validation State

**Approach:** Allow `rescan` only while document is in scan-related states (`quick_scan_*`, `awaiting_validation`) and reject if confirmed or already in deep pipeline.

**Pros:**
- Preserves state-machine invariants.
- Small implementation surface.

**Cons:**
- Requires explicit allowed-state list maintenance.

**Effort:** Small  
**Risk:** Low

### Option 2: Soft Rescan Request Queue

**Approach:** Persist a rescan-request flag and process only when safe (before confirmation), otherwise ignore with idempotent response.

**Pros:**
- Handles timing edges more gracefully.

**Cons:**
- More complexity than needed for current flow.

**Effort:** Medium  
**Risk:** Medium

## Recommended Action

Implemented Option 1:
- Added a `rescan` state guard to reject requests unless the document is still in scan-validation states.
- Explicitly return `409` when attempting to rescan confirmed or deep-processing documents.
- Added feature tests covering both rejection paths and no-dispatch guarantees.

## Technical Details

- Affected endpoint: `POST /api/v1/children/{child}/documents/{document}/rescan`
- File: `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php`

## Acceptance Criteria

- [x] `rescan` is rejected for confirmed documents and deep-generation stages.
- [x] Response code/message is explicit (e.g., 409 conflict with state explanation).
- [x] Feature test covers: confirmed doc -> rescan rejected and no scan job dispatched.

## Work Log

### 2026-02-09 - Code Review Finding

**By:** Codex

**Actions:**
- Reviewed post-fix scan/confirm/rescan state transitions.
- Identified missing state guard on `rescan`.

**Learnings:**
- State machine hardening requires both forward-transition guards and regression guards.

### 2026-02-09 - Resolution

**By:** Codex

**Actions:**
- Updated `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php`:
  - Added `canRescanDocument()` state guard.
  - `rescan` now returns `409` with explicit message when state is not rescannable.
- Added feature tests in `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/Feature/DocumentUploadTest.php`:
  - `test_rescan_rejects_confirmed_document_and_does_not_dispatch_job`
  - `test_rescan_rejects_document_already_in_deep_processing_stage`

**Validation:**
- `php -l` passed for changed backend files.
- `php artisan test tests/Feature/DocumentUploadTest.php` is blocked in this environment by missing PHP MongoDB extension (`Class "MongoDB\\Driver\\Manager" not found`).

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php:95`
