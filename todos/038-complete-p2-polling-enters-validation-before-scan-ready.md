---
status: complete
priority: p2
issue_id: "038"
tags: [code-review, flutter, state-management, reliability]
dependencies: []
---

# Polling Enters Validation State Before Quick Scan Is Ready

## Problem Statement

The mobile polling loop switches to `awaitingScanValidation` whenever `validation_status == pending`, even during `quick_scan_queued`/`quick_scan_processing`. This can stop polling too early and show validation UI before suggestions are ready.

## Findings

- Current condition:
  - `if (docStage == 'awaiting_validation' || validationStatus == 'pending')`
- Because upload initializes `validation_status = pending`, this condition is true before quick scan completes.
- The function returns immediately after setting awaiting-validation UI state.
- Evidence:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1364`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1387`

## Proposed Solutions

### Option 1: Stage-First Gating

**Approach:** Enter validation UI only when `docStage == 'awaiting_validation'` (or scan failed with explicit fallback stage).

**Pros:**
- Simple and aligned with backend stage machine.
- Prevents premature UI transitions.

**Cons:**
- Requires backend stage values to remain authoritative and stable.

**Effort:** Small  
**Risk:** Low

### Option 2: Compound Condition

**Approach:** Use `validation_status == pending` only when `scan_status in {ready, failed}`.

**Pros:**
- Robust even if stage has short delays.

**Cons:**
- Slightly more logic complexity.

**Effort:** Small  
**Risk:** Low

## Recommended Action

Implemented compound guard:
- Validation UI is shown only for explicit validation/failure stages or when scan is actually ready.
- Removed broad `validation_status == pending` early return behavior.

## Technical Details

- Affected polling path: `_pollForPackAndQuiz(...)`
- Primary file: `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`

## Acceptance Criteria

- [x] App does not show validation UI while scan is still queued/processing.
- [x] Polling continues until scan reaches ready/failed validation stage.
- [ ] State test covers `pending + quick_scan_processing` and confirms no premature return.

## Work Log

### 2026-02-09 - Code Review Finding

**By:** Codex

**Actions:**
- Traced polling control-flow and state updates for quick-scan lifecycle.
- Identified early return condition tied to broad `pending` status.

**Learnings:**
- Validation state should be driven by explicit pipeline stage or scan readiness, not by pending flag alone.

### 2026-02-09 - Resolution

**By:** Codex

**Actions:**
- Updated polling predicate in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart` to:
  - allow validation on `awaiting_validation`,
  - allow validation on `quick_scan_failed`,
  - allow validation when `validation_status == pending && scan_status == ready`.

**Validation:**
- `flutter analyze` passed on the modified files.

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1364`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1387`
