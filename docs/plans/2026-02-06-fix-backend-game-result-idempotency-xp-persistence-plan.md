---
title: "fix: Harden Backend Game Result Idempotency and XP Persistence"
type: fix
date: 2026-02-06
---

# fix: Harden Backend Game Result Idempotency and XP Persistence

## Overview

Close the remaining backend integrity gaps in game result ingestion:

1. Ensure retries do not double-apply mastery/streak/XP updates.
2. Ensure `xp_earned` is reliably persisted in `game_results`.
3. Add regression tests for idempotent result submission behavior.

This plan is scoped to backend-first changes and keeps current mobile behavior compatible.

## Idea Refinement

- No recent brainstorm file found in `docs/brainstorms/`.
- Feature description is clear and implementation-focused.
- Proceeding directly to research and planning.

## Local Research Summary

### Repo Findings

- Result submission endpoint always creates and re-applies progression logic:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:49`
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:67`
- `GameResult` model does not list `xp_earned` in `$fillable`:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Models/GameResult.php:14`
- Mobile now retries failed submissions (2 attempts), which increases duplicate-write risk:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1227`
- Backend tests currently do not include a dedicated result-ingestion idempotency test:
  - Existing feature tests list from `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/Feature/*.php`
- Base test cleanup does not currently drop `game_results`:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/TestCase.php:14`

### Learnings Research

- No institutional learnings found in `docs/solutions/` for this issue.

### Research Decision

This is a data-integrity path, but local code context is strong and specific enough to produce a grounded implementation plan without external dependency research.

## SpecFlow Analysis

### Primary Flow

1. Child completes game.
2. Mobile submits `POST /results`.
3. Backend persists `game_results`.
4. Backend updates `mastery_profiles`.
5. Backend updates `child_profiles` streak and XP.
6. Client receives streak/XP payload.

### Critical Edge Cases

- Network retry sends same logical completion twice.
- Duplicate submissions race in parallel.
- Duplicate record path must not re-run progression side effects.
- Existing data may already contain duplicates, impacting unique index rollout.

### Spec Gaps to Resolve

- Define idempotency key strategy for current API (backend-only version).
- Define HTTP response contract for replayed submissions without breaking current mobile client.
- Define rollout and verification steps for unique index creation.

## Proposed Solution

### Core Decisions

1. Treat `(child_profile_id, game_id)` as the idempotency boundary for v1.
2. Persist exactly one `game_results` record per child/game pair.
3. Execute mastery/streak/XP updates only on first insert.
4. Preserve backward compatibility by returning `201` for both first-write and idempotent replay in v1 (with `idempotent_replay` metadata).

### Why This Design

- Mobile retries currently keep the same `gameId`, so this key is stable.
- Avoids immediate client contract changes while fixing integrity.
- Minimizes scope compared to introducing a new client-generated submission UUID right now.

## Technical Approach

### Phase 1: Data Model Safety (Small)

**Files**
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Models/GameResult.php`

**Changes**
- Add `xp_earned` to `$fillable`.
- Add `xp_earned` to `$casts` as integer.

### Phase 2: Idempotent Controller Path (Medium)

**Files**
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php`

**Changes**
- Replace unconditional `GameResult::create(...)` with idempotent lookup/create flow keyed by `(child_profile_id, game_id)`.
- Ensure progression side effects run only when record is newly created.
- For replay submissions:
  - return existing record
  - do not modify `mastery_profiles` or `child_profiles`
  - include flag: `idempotent_replay: true`
- Keep response status `201` for compatibility with current mobile client behavior.

**Pseudo-code**

```php
// backend/app/Http/Controllers/Api/GameResultController.php
$record = GameResult::firstOrCreate(
  ['child_profile_id' => $childId, 'game_id' => $gameId],
  [/* full payload including xp_earned */]
);

if ($record->wasRecentlyCreated) {
  $this->updateMastery($child, $results);
  $streakData = $this->updateStreak($child, $xpEarned);
} else {
  $streakData = [
    'streak_days' => $child->fresh()->streak_days ?? 0,
    'total_xp' => $child->fresh()->total_xp ?? 0,
  ];
}

return response()->json([
  'data' => $record,
  'xp_earned' => $record->xp_earned,
  'total_xp' => $streakData['total_xp'],
  'streak_days' => $streakData['streak_days'],
  'idempotent_replay' => ! $record->wasRecentlyCreated,
], 201);
```

### Phase 3: Index Hardening (Medium)

**Files**
- New command or deployment script under backend tooling (`backend/app/Console/Commands/...` recommended)

**Changes**
- Add one-time index creation for `game_results`:
  - unique compound index on `{ child_profile_id: 1, game_id: 1 }`.
- Add preflight duplicate detector and report output before index creation.

**Operational requirement**
- If duplicates exist, pause index creation and run cleanup procedure first.

### Phase 4: Test Coverage (Medium)

**Files**
- New: `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/Feature/GameResultSubmissionTest.php`
- Update: `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/TestCase.php`

**Test cases**
- First submission creates result and updates mastery/streak/XP.
- Replay submission for same `(child, game)` does not double increment XP or mastery attempts.
- `xp_earned` exists and is persisted in stored record.
- Test isolation includes dropping `game_results` in base test cleanup.

## Alternative Approaches Considered

### Option A: Add `client_submission_id` (UUID) immediately

Pros:
- More explicit idempotency contract.
- Better long-term multi-device semantics.

Cons:
- Requires coordinated mobile/backend rollout now.
- Larger immediate scope.

Decision:
- Defer to follow-up enhancement after backend v1 hardening lands.

### Option B: Keep current behavior and rely on client fallback

Pros:
- No backend changes.

Cons:
- Data corruption/over-count risk remains.
- Violates progression integrity goals.

Decision:
- Rejected.

## Dependencies & Risks

### Dependencies

- Existing auth and child/game ownership checks stay unchanged.
- Mobile currently expects `201`; this plan preserves that contract.

### Risks

- Existing duplicate rows can block unique index creation.
- If replay response semantics drift later (e.g., to `200`), mobile client must be updated in lockstep.

### Mitigations

- Add duplicate preflight report as part of rollout.
- Keep idempotent replay at `201` in this phase.
- Add automated regression tests before rollout.

## Acceptance Criteria

### Functional

- [x] Submitting the same `(child_id, game_id)` twice does not create two `game_results` records.
- [x] Replay submission does not re-apply mastery updates.
- [x] Replay submission does not increment streak/XP again.
- [x] `xp_earned` is persisted and returned from stored record.

### Non-Functional

- [x] Idempotent path remains backward compatible with current mobile client response handling.
- [x] Unique index rollout has a documented preflight and failure path.

### Quality Gates

- [x] New feature tests for game result idempotency pass.
- [x] Existing backend test suite passes.
- [x] Manual API smoke test verifies first submit vs replay behavior.

## Success Metrics

- Duplicate replay submissions produce zero additional XP/mastery increments.
- `game_results` has no duplicate `(child_profile_id, game_id)` entries post-rollout.
- No regression in `/results` mobile flow after deployment.

## Implementation Checklist

- [x] Update `GameResult` model fillable/casts for `xp_earned`.
- [x] Implement idempotent create/replay behavior in `GameResultController`.
- [x] Add replay metadata field to response payload.
- [x] Add duplicate preflight + unique index creation command/script.
- [x] Add `GameResultSubmissionTest` feature tests.
- [x] Add `game_results` to test DB cleanup list in `Tests\TestCase`.
- [x] Run backend test suite and lint.
- [x] Validate replay behavior with manual API calls.

## References & Research

### Internal References

- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:16`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Models/GameResult.php:14`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/TestCase.php:14`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1227`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart:292`

### Related Work

- `/Users/benoit/Documents/Projects/P3rform/learny/docs/plans/2026-02-06-feat-complete-quiz-learning-pipeline-plan.md`
- `/Users/benoit/Documents/Projects/P3rform/learny/todos/007-complete-p1-local-fallback-skipped-when-result-identifiers-missing.md`
- `/Users/benoit/Documents/Projects/P3rform/learny/todos/008-complete-p2-submit-result-no-retry-on-transient-failure.md`
