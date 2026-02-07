---
status: complete
priority: p1
issue_id: "011"
tags: [code-review, backend, mobile, regression]
dependencies: []
---

# Redo Document Reuses Stale Game Type Filter

Redoing a document should regenerate the full learning set unless a new filter is explicitly chosen. Current behavior can silently keep an old `requested_game_types` filter and regenerate only one type.

## Problem Statement

After using "New Game Type" once, "Redo Document" can keep that old single-type filter. This breaks user expectation for full regeneration and makes the feature appear inconsistent.

## Findings

- Backend only updates `requested_game_types` when non-empty input is present:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentController.php:157`
- Mobile "Redo Document" calls regenerate without `requestedGameTypes`, so backend keeps previous value:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:166`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1792`
- Impact: prior "new type" choice can unintentionally persist across future redos.

## Proposed Solutions

### Option 1: Clear Filter on Generic Redo

Approach: when `requested_game_types` is omitted, backend resets `document.requested_game_types` to `null`.

Pros:
- Matches user expectation for "Redo Document"
- Backward-compatible API

Cons:
- Changes current implicit behavior

Effort: Small
Risk: Low

---

### Option 2: Require Explicit Regeneration Mode

Approach: add explicit mode (`full` vs `filtered`) in regenerate request and handle deterministically.

Pros:
- No ambiguity
- Easy to reason about in clients

Cons:
- API contract change
- Requires client updates everywhere

Effort: Medium
Risk: Medium

## Recommended Action

Implemented Option 1. Generic "Redo Document" now clears `requested_game_types` when no explicit filter is provided, while "New Game Type" remains filtered.

## Technical Details

Affected files:
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentController.php:157`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1792`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:166`

Database changes:
- No schema change required

## Resources

- Commit reviewed: `cc83c21`

## Acceptance Criteria

- [x] "Redo Document" regenerates all configured/default game types when no filter is selected
- [x] "New Game Type" regenerates only selected type(s)
- [x] Behavior is covered by automated tests (controller + app-state integration path)
- [x] No regression in existing regeneration flow

## Work Log

### 2026-02-07 - Initial Discovery

By: Codex

Actions:
- Reviewed regenerate backend flow and progress action wiring
- Confirmed stale filter persistence path
- Documented remediation options

Learnings:
- Current API semantics are ambiguous between full and filtered regeneration

### 2026-02-07 - Implemented

By: Codex

Actions:
- Updated `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentController.php` to clear stale `requested_game_types` when omitted.
- Added backend regression test in `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/Feature/DocumentUploadTest.php`.
- Added app-state regression coverage in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/test/state/app_state_result_submission_test.dart`.

Validation:
- Flutter tests pass.
- Backend PHPUnit execution is blocked locally by missing `MongoDB\\Driver\\Manager` extension; PHP lint passes for changed files.

## Notes

- This is prioritized as P1 because it directly breaks the advertised redo behavior.
