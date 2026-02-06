---
status: ready
priority: p1
issue_id: "010"
tags: [planning, backend, mobile, revision, memory]
dependencies: []
---

# Smart Revision Burst Execution

Execute the smart revision plan with a methodical, test-first vertical slice focused on backend revision sessions, bound-user guardrails, and mobile integration.

## Problem Statement

Revision is still locally fake, memory events are not persisted as first-class events, and bound-user testing mode is not implemented.

## Recommended Action

1. Add bound-user resolver mode for non-production with production fail-fast guard.
2. Add backend revision session compose + submit endpoints and persistence.
3. Add learning memory event model and write events from game/revision flows.
4. Integrate mobile revision flow with backend fetch/submit.
5. Add/adjust tests and update plan checkboxes.

## Acceptance Criteria

- [x] Bound-user mode works in non-production and is blocked in production.
- [x] `GET /v1/children/{child}/revision-session` composes items from real backend signals.
- [x] `POST /v1/children/{child}/revision-session/{session}/results` persists outcomes and returns aggregate stats.
- [x] `learning_memory_events` records are written for game results and revision results.
- [x] Mobile revision session starts from backend data and submits results back.
- [ ] Backend and Flutter tests for changed behavior pass.

## Work Log

### 2026-02-06 - Task List Created

**By:** Codex

**Actions:**
- Created execution checklist and ordering for burst implementation.
- Prioritized Track E + Track A + memory event write path as first shippable vertical slice.

**Learnings:**
- A narrow, tested slice de-risks the larger all-at-once execution model.

### 2026-02-06 - Track E + Track A Slice Implemented

**By:** Codex

**Actions:**
- Added non-production bound-child resolution with production fail-fast guard:
  - `backend/config/learny.php`
  - `backend/app/Concerns/FindsOwnedChild.php`
  - `backend/app/Providers/AppServiceProvider.php`
  - `backend/tests/Feature/BoundChildModeTest.php`
- Added backend revision session compose + submit flow:
  - `backend/app/Http/Controllers/Api/RevisionSessionController.php`
  - `backend/app/Services/Revision/RevisionComposer.php`
  - `backend/app/Models/RevisionSession.php`
  - `backend/routes/api.php`
  - `backend/tests/Feature/RevisionSessionTest.php`
- Added memory event write model and hooks:
  - `backend/app/Models/LearningMemoryEvent.php`
  - `backend/database/migrations/2026_02_06_000002_create_revision_and_memory_indexes.php`
  - `backend/app/Http/Controllers/Api/GameResultController.php`
  - `backend/tests/Feature/GameResultSubmissionTest.php`
- Added mobile backend revision integration:
  - `mobile/learny_app/lib/services/backend_client.dart`
  - `mobile/learny_app/lib/state/app_state.dart`
  - `mobile/learny_app/lib/models/revision_session.dart`
  - `mobile/learny_app/lib/screens/revision/revision_setup_screen.dart`
  - `mobile/learny_app/lib/screens/revision/revision_session_screen.dart`

**Validation:**
- `php -l` passed for all changed PHP files.
- `flutter test test/state/app_state_result_submission_test.dart` passed.
- `flutter test test/widget_test.dart` passed.
- `flutter analyze` still reports pre-existing info-level diagnostics unrelated to this slice.
- `php artisan test --filter=...` could not run due missing MongoDB PHP extension (`MongoDB\\Driver\\Manager` not found) in this environment.

**Learnings:**
- Revision can be backend-first while retaining a local fallback for resilience.
- Bound-child testing mode is safe only with explicit production startup guard.
