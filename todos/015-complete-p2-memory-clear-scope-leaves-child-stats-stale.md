---
status: complete
priority: p2
issue_id: "015"
tags: [code-review, data-integrity, backend, mobile]
dependencies: []
---

# Memory Clear Scope Leaves Child Stats Stale

Clearing memory scope can delete core learning records without reconciling derived child stats, leading to inconsistent streak/XP state.

## Problem Statement

`clear-scope` can remove `game_results` and `mastery_profiles` but does not recalculate or reset `child_profiles.total_xp` / `streak_days`. Mobile also does not refresh child profile post-clear. This can present stale progression after destructive memory actions.

## Findings

- In `backend/app/Http/Controllers/Api/MemoryPreferencesController.php:77`, `game_results` can be deleted for a child.
- In `backend/app/Http/Controllers/Api/MemoryPreferencesController.php:81`, `mastery_profiles` can be deleted.
- No recalculation/update of `child_profiles.total_xp`, `streak_days`, `longest_streak`, or `last_activity_date` occurs before response.
- In `mobile/learny_app/lib/state/app_state.dart:1909`, post-clear refresh updates review/activities/recommendations only; child profile stats are not rehydrated.

## Proposed Solutions

### Option 1: Reconcile Child Aggregates During Clear (Recommended)

**Approach:** In `clearScope`, recompute and persist child aggregate fields based on remaining records (or reset to zero when clearing all).

**Pros:**
- Immediate consistency after clear
- Single backend source of truth

**Cons:**
- Adds backend write logic to destructive endpoint

**Effort:** 3-5 hours

**Risk:** Medium

---

### Option 2: Async Reconciliation Job

**Approach:** Emit a reconciliation job after clear; return early.

**Pros:**
- Keeps controller lean
- Scales better for heavy data sets

**Cons:**
- Temporary inconsistency window
- Requires queue observability and retries

**Effort:** 1 day

**Risk:** Medium

---

### Option 3: Restrict Clear Scope to Non-Derived Data

**Approach:** Remove `game_results`/`mastery_profiles` from clearable scopes.

**Pros:**
- Avoids aggregate inconsistency entirely

**Cons:**
- Reduces admin/parent control
- Conflicts with current endpoint contract

**Effort:** 1-2 hours

**Risk:** Medium

## Recommended Action

Triage recommendation: implement Option 1 and include child aggregate values in clear-scope response so mobile can apply immediate state updates.

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/MemoryPreferencesController.php:77`
- `backend/app/Http/Controllers/Api/MemoryPreferencesController.php:81`
- `mobile/learny_app/lib/state/app_state.dart:1909`

**Related components:**
- Child profile streak/xp display
- Progress overview and motivation surfaces

## Resources

- Commit: `2f869c0`
- Plan: `docs/plans/2026-02-07-feat-learning-experience-next-wave-plan.md`

## Acceptance Criteria

- [x] After any clear-scope call, child aggregate stats are internally consistent with retained data
- [x] Mobile refreshes child-level progression after clear operations
- [x] Contract test covers `scope=all` and `scope=game_results`
- [x] No stale streak/XP values remain visible after clear

## Work Log

### 2026-02-07 - Review Finding

**By:** Codex

**Actions:**
- Traced clear-scope deletion flow in backend
- Checked mobile post-clear refresh path
- Verified no aggregate reconciliation is currently performed

**Learnings:**
- Deleting source records without recalculating derived fields creates data integrity drift

### 2026-02-08 - Implementation Completed

**By:** Codex

**Actions:**
- Added child aggregate reconciliation in `backend/app/Http/Controllers/Api/MemoryPreferencesController.php` after clear-scope operations
- Included `child_summary` payload in clear-scope response for immediate client sync
- Updated `mobile/learny_app/lib/state/app_state.dart` to apply server child summary and refresh packs/review/recommendations after clear
- Expanded assertions in `backend/tests/Feature/MemoryPreferencesTest.php` and `mobile/learny_app/test/state/app_state_result_submission_test.dart`

**Learnings:**
- Returning authoritative post-mutation child summary removes stale streak/XP windows in the UI

## Notes

- This is high-impact for trust in progression/motivation UX.
