---
status: complete
priority: p1
issue_id: "007"
tags: [code-review, mobile, reliability, gamification]
dependencies: []
---

# Apply Local Progress Fallback When Submission IDs Are Missing

`_submitGameResults()` exits early when `childId`, `packId`, or `gameId` is null, but this path does not apply the local fallback progression update. As a result, users can finish a game and receive no XP/streak update at all.

## Problem Statement

The current implementation intends to keep backend data authoritative while degrading gracefully when backend submission fails. However, there is an early-return branch that bypasses both backend submission and fallback logic, creating a silent no-op on progression.

This breaks the expected "fallback when backend unavailable" behavior and can make completions appear lost.

## Findings

- Early return occurs before fallback handling in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1208`.
- Fallback progression logic exists (`_applyLocalGamificationFallback`) but is only called from exception handling, not from the missing-identifier path in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1277`.
- This can happen when game metadata is incomplete (for example, local/fake-only flows or partially initialized backend session), causing no progression update.

## Proposed Solutions

### Option 1: Invoke Fallback Before Early Return (Recommended)

**Approach:** In the `childId/packId/gameId` null guard, call `_applyLocalGamificationFallback(correctAnswers: correctAnswers)` and set `lastResultSyncError` before returning.

**Pros:**
- Minimal code change.
- Preserves existing flow and makes fallback deterministic.

**Cons:**
- Does not distinguish between transient missing IDs and programmer errors.

**Effort:** Small  
**Risk:** Low

---

### Option 2: Treat Missing IDs As Hard Errors

**Approach:** Throw a typed exception for missing identifiers and let unified catch logic apply fallback + messaging.

**Pros:**
- Single failure pathway.
- Better observability and debugging.

**Cons:**
- Slightly more refactor to keep call sites predictable.

**Effort:** Small  
**Risk:** Medium

## Recommended Action

Implement Option 1 immediately, then add a regression test for completion flows with missing IDs to verify XP/streak fallback is still applied.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1192`

**Related components:**
- Game completion pipeline
- Results summary / gamification state

## Acceptance Criteria

- [x] If `childId/packId/gameId` is missing at submission time, XP fallback is still applied.
- [x] `lastResultSyncError` is set with an actionable message for this branch.
- [x] Results screen still shows a coherent outcome and non-blocking sync warning.
- [x] Automated test covers the missing-identifier path.

## Work Log

### 2026-02-06 - Review Finding

**By:** Codex

**Actions:**
- Reviewed the new unified completion/submission flow.
- Traced all return paths in `_submitGameResults()`.
- Verified fallback logic is not executed in missing-identifier early return.

**Learnings:**
- Error-handling parity across all early exits is required to keep the "degrade gracefully" promise.

### 2026-02-06 - Resolution

**By:** Codex

**Actions:**
- Updated `_submitGameResults` to apply `_applyLocalGamificationFallback` before returning on missing `childId/packId/gameId`.
- Added explicit `lastResultSyncError` message and debug log for this branch.
- Added regression test `applies local fallback when identifiers are missing` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/test/state/app_state_result_submission_test.dart`.

**Learnings:**
- Missing-identifier branches must honor the same fallback contract as network failures.
