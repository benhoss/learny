---
status: complete
priority: p2
issue_id: "012"
tags: [code-review, mobile, reliability, ux]
dependencies: []
---

# Activity Actions Need Error Handling And Tap Guard

Activity action buttons trigger async operations but do not provide robust failure UX or protection against repeated rapid taps.

## Problem Statement

Users can trigger duplicate regenerate/start requests by tapping repeatedly, and failures from async operations are not surfaced consistently. This can cause unnecessary backend load and confusing UX.

## Findings

- Action callbacks invoke async handlers without in-flight guard:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:387`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:394`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:400`
- `regenerateDocument` has no local try/catch and no user-facing error mapping:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1792`
- Result: duplicate dispatches and opaque failures under network/API errors.

## Proposed Solutions

### Option 1: Per-Action In-Flight Flags + Unified Error Snackbar

Approach: add local loading state in activity cards and disable buttons while action runs; wrap calls with try/catch and show actionable errors.

Pros:
- Fast and local fix
- Prevents accidental burst requests
- Better user feedback

Cons:
- Some UI state plumbing needed

Effort: Small
Risk: Low

---

### Option 2: Centralized Command Queue in AppState

Approach: route all activity actions through AppState command methods with dedupe keys and standardized status/error events.

Pros:
- Consistent behavior across app
- Better extensibility for retries/telemetry

Cons:
- Larger refactor

Effort: Medium
Risk: Medium

## Recommended Action

Implemented Option 1. Activity actions are now guarded per card while async work is running, and failures surface as snackbars.

## Technical Details

Affected files:
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:387`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1792`

Database changes:
- No

## Resources

- Commit reviewed: `cc83c21`

## Acceptance Criteria

- [x] Each activity action disables while request is in progress
- [x] Repeated taps do not create duplicate backend calls
- [x] Failures show clear snackbar/toast message
- [x] Happy path still navigates and updates activity list correctly

## Work Log

### 2026-02-07 - Initial Discovery

By: Codex

Actions:
- Reviewed UI action handlers and state methods for retry/guard behavior
- Identified missing in-flight and failure UX safeguards

Learnings:
- Current UX can overwhelm backend under rapid interaction.

### 2026-02-07 - Implemented

By: Codex

Actions:
- Converted activity cards to stateful guarded actions in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart`.
- Added explicit success/failure feedback for redo/generate actions.
- Updated `regenerateDocument` to return success/failure status from `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`.

Validation:
- Flutter tests pass (`test/state/app_state_result_submission_test.dart`, `test/widget_test.dart`).

## Notes

- This is P2: high reliability impact but non-blocking for merge if controlled usage.
