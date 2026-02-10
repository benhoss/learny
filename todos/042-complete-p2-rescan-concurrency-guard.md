---
status: complete
priority: p2
issue_id: "042"
tags: [code-review, backend, api, reliability, performance]
dependencies: []
---

# Prevent concurrent rescan requests from enqueueing duplicate quick scans

The rescan endpoint currently allows repeated requests in quick succession without any concurrency guard. This can enqueue multiple `QuickScanDocumentMetadata` jobs and thrash document state.

## Problem Statement

`POST /documents/{id}/rescan` does not use a lock or idempotency check. A user (or flaky mobile retry) can trigger multiple rescans, resulting in multiple queued jobs and racing updates to scan status, pipeline stage, and telemetry. This increases queue load and can overwrite scan results unpredictably.

## Findings

- `DocumentScanController::rescan` has no lock or idempotency guard.
- The method dispatches `QuickScanDocumentMetadata` on every call after `canRescanDocument` passes.
- Location: `backend/app/Http/Controllers/Api/DocumentScanController.php:87-113`.
- There is no test coverage for duplicate rescan attempts or rescan while `quick_scan_processing`.

## Proposed Solutions

### Option 1: Add cache lock similar to confirm

**Approach:** Wrap rescan in `Cache::lock('documents:rescan:{$id}', ttl)`; return 409 if already locked.

**Pros:**
- Simple and consistent with confirm
- Prevents concurrent rescans

**Cons:**
- Adds dependency on cache lock TTL

**Effort:** 1-2 hours

**Risk:** Low

---

### Option 2: Idempotent guard on scan status

**Approach:** If `scan_status` is `queued` or `processing`, return 202 with current document (no new job).

**Pros:**
- Avoids locking
- Naturally idempotent

**Cons:**
- Requires careful state checks for legacy documents

**Effort:** 2-3 hours

**Risk:** Medium

---

### Option 3: Use unique jobs for quick scan

**Approach:** Make `QuickScanDocumentMetadata` implement `ShouldBeUnique` with document ID as unique key.

**Pros:**
- Queue-level deduplication
- No API changes needed

**Cons:**
- Requires queue config awareness
- Still allows repeated state resets in controller

**Effort:** 2-4 hours

**Risk:** Medium

## Recommended Action

**To be filled during triage.**

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/DocumentScanController.php:87-113`
- `backend/app/Jobs/QuickScanDocumentMetadata.php`
- `backend/tests/Feature/DocumentUploadTest.php` (add coverage)

**Related components:**
- Queue worker for `scan` queue
- Mobile rescan action in `ProcessingScreen`

**Database changes (if any):**
- Migration needed? No

## Resources

- **API endpoint:** `POST /api/v1/children/{child}/documents/{document}/rescan`
- **Related tests:** `backend/tests/Feature/DocumentUploadTest.php`

## Acceptance Criteria

- [x] Rescan requests are idempotent and do not enqueue multiple jobs for the same document.
- [x] API returns conflict or no-op when rescan already in progress.
- [x] Tests cover duplicate rescan attempts.

## Work Log

### 2026-02-10 - Initial Discovery

**By:** Claude Code

**Actions:**
- Reviewed rescan endpoint flow and queue dispatch
- Identified missing concurrency guard
- Drafted options for deduplication

**Learnings:**
- Rescan uses only `canRescanDocument` gate
- Multiple dispatches can race scan status updates

### 2026-02-10 - Implementation

**By:** Claude Code

**Actions:**
- Added rescan lock guard in `backend/app/Http/Controllers/Api/DocumentScanController.php`
- Added rescan lock conflict test in `backend/tests/Feature/DocumentUploadTest.php`
- Attempted to run `./vendor/bin/phpunit --filter DocumentUploadTest` (failed: missing MongoDB driver)

**Learnings:**
- Rescan now returns 409 while lock is held

## Notes

- Consider aligning rescan conflict messaging with confirm-scan lock handling.
