---
status: ready
priority: p1
issue_id: "035"
tags: [backend, flutter, ai-pipeline, upload]
dependencies: []
---

# Implement Two-Stage Scan Validation Pipeline

## Problem Statement

Document generation starts immediately after upload, without an explicit user validation checkpoint for AI-detected topic/language.

## Findings

- Upload currently dispatches OCR immediately from `DocumentController@store`.
- Processing UI assumes continuous pipeline to `ready` and has no validation checkpoint.
- Metadata suggestion exists but is optional and decoupled from the upload job flow.

## Proposed Solutions

### Option 1: Hard gate in backend + explicit validation UI (chosen)

**Approach:** Insert quick-scan stage after upload and require confirm endpoint before OCR dispatch.

**Pros:** Clear control point, reduced bad generations, measurable gate telemetry.

**Cons:** Adds one extra step before deep generation.

**Effort:** 1-2 days

**Risk:** Medium

## Recommended Action

Implement backend pipeline gate first, then wire Flutter processing state/UI to confirm scan and resume generation.

## Acceptance Criteria

- [x] Upload dispatches quick scan, not OCR.
- [x] Document exposes scan suggestion + validation status.
- [x] Confirm scan endpoint dispatches OCR idempotently.
- [x] Flutter handles awaiting-validation state and confirm action.
- [x] Backend tests cover upload->awaiting_validation and confirm->deep pipeline.

## Work Log

### 2026-02-09 - Start implementation

**By:** Codex

**Actions:**
- Created feature branch `codex/feat-two-stage-document-scan-validation`.
- Started implementation from `/Users/benoit/Documents/Projects/P3rform/learny/docs/plans/2026-02-09-feat-two-stage-document-scan-validation-pipeline-plan.md`.

**Learnings:**
- Existing queue lanes and pipeline telemetry can be reused with minimal architecture change.

### 2026-02-09 - Core implementation completed

**By:** Codex

**Actions:**
- Added quick-scan job/service and scan endpoints (`show`, `confirm`, `rescan`).
- Gated deep pipeline so OCR starts only after explicit scan confirmation.
- Updated Flutter processing flow to pause on `awaiting_validation` and allow confirm/rescan.
- Added backend test coverage for upload gate, idempotent confirm, and rescan behavior.

**Validation:**
- Ran: `docker compose run --rm --no-deps app php artisan test tests/Feature/DocumentUploadTest.php tests/Feature/DocumentMetadataSuggestionTest.php tests/Feature/GenerationPipelineTest.php`
- Result: 7 passing tests, 0 failures.

### 2026-02-09 - Review findings addressed

**By:** Codex

**Actions:**
- Fixed quick-scan/confirm race protections in backend.
- Added lock-based confirmation guard and contention handling.
- Tightened Flutter validation polling condition to avoid premature validation UI.
- Localized quick-scan stage/status strings in screens and ARB files.
- Closed review findings 036-039 as complete.

**Validation:**
- `flutter analyze lib/screens/documents/library_screen.dart lib/screens/documents/processing_screen.dart lib/state/app_state.dart` passed.
- Backend runtime tests are currently blocked in this environment:
  - Docker daemon unavailable.
  - Local PHP runtime missing `MongoDB\Driver\Manager` extension.
