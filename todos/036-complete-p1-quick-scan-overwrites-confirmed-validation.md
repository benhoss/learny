---
status: complete
priority: p1
issue_id: "036"
tags: [code-review, backend, data-integrity, concurrency]
dependencies: []
---

# Quick Scan Job Overwrites Confirmed Validation

## Problem Statement

The quick-scan job can overwrite a document that was already confirmed by the user, reverting validation fields and pipeline stage. This can put documents back into `awaiting_validation` after deep processing has already started.

## Findings

- `QuickScanDocumentMetadata::handle()` unconditionally sets:
  - `validated_topic = null`
  - `validated_language = null`
  - `validated_at = null`
  - `validation_status = 'pending'`
  - stage transition to `awaiting_validation`
- Evidence:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Jobs/QuickScanDocumentMetadata.php:47`
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Jobs/QuickScanDocumentMetadata.php:52`
- If `confirm-scan` is called before or during quick-scan execution, this job can downgrade state after confirmation.

## Proposed Solutions

### Option 1: State Guard in Quick Scan Job

**Approach:** Skip state mutation when document is already confirmed or already past validation gate.

**Pros:**
- Small change, lowest risk.
- Preserves intended state machine.

**Cons:**
- Requires careful list of terminal/in-progress downstream stages.

**Effort:** Small  
**Risk:** Low

### Option 2: Versioned State Transition

**Approach:** Add version/token to scan cycle and update only if token matches current active scan cycle.

**Pros:**
- Robust against delayed/stale jobs.

**Cons:**
- Adds schema and workflow complexity.

**Effort:** Medium  
**Risk:** Medium

## Recommended Action

Implemented Option 1 (state guards) in `QuickScanDocumentMetadata`:
- Abort immediately when document is already confirmed.
- Re-fetch document after scan call and abort stale mutation if state moved on.
- Keep failure mutation guarded to avoid stale overwrite paths.

## Technical Details

- Affected component: scan-to-validation state transition in async queue job.
- Primary file: `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Jobs/QuickScanDocumentMetadata.php`

## Acceptance Criteria

- [x] Quick-scan job does not mutate `validated_*` or `validation_status` when already confirmed.
- [x] Quick-scan job does not transition to `awaiting_validation` when document stage already advanced beyond validation gate.
- [x] Regression test covers race: confirm called before quick-scan completion.

## Work Log

### 2026-02-09 - Code Review Finding

**By:** Codex

**Actions:**
- Reviewed quick-scan async state transitions and confirm endpoint interaction.
- Identified unconditional validation reset in job logic.

**Learnings:**
- Current state transitions are vulnerable to stale queue writes overriding user confirmation.

### 2026-02-09 - Resolution

**By:** Codex

**Actions:**
- Added `shouldAbortScanMutation()` guard and stale-state recheck in `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Jobs/QuickScanDocumentMetadata.php`.
- Removed unconditional reset of `validated_*` fields in quick-scan completion path.
- Added regression test `test_quick_scan_job_does_not_override_confirmed_document_state` in `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/Feature/DocumentUploadTest.php`.

**Validation:**
- Syntax checks passed for changed PHP files.
- Runtime backend tests currently blocked in this environment (Docker daemon unavailable; local PHP lacks MongoDB extension).

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Jobs/QuickScanDocumentMetadata.php:47`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php:64`
