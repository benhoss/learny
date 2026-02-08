---
status: complete
priority: p1
issue_id: "009"
tags: [planning, backend, mobile, reliability]
dependencies: []
---

# Close Remaining Plan Gaps

Address the remaining implementation mismatches between `docs/plans` and current code so the completed plans are also accurate in behavior.

## Problem Statement

The plans are fully checked, but a few runtime behaviors and contracts are still inconsistent with intended outcomes.

## Findings

- Review queue `total_due` currently reflects the limited page count, not total due count.
- `ChildProfile` defaults/casts include streak/XP fields, but `$fillable` omits them.
- Mobile pack progression still applies local synthetic progress increments.
- Concept extraction is still bound to stub unconditionally.

## Recommended Action

1. Fix backend review queue response to return actual total due count.
2. Align `ChildProfile` `$fillable` with declared progression fields.
3. Remove local synthetic pack mastery increment and refresh pack mastery from backend after result submission.
4. Add a production concept extractor implementation and bind it when OpenRouter is configured.

## Acceptance Criteria

- [x] `GET /review-queue` returns `total_due` for all due concepts, while response `data` remains paginated.
- [x] `ChildProfile` model allows streak/XP fields in `$fillable`.
- [x] Pack progress no longer increments by local fixed offsets.
- [x] After game submission success, pack mastery/progress is refreshed from backend data.
- [x] Concept extractor binding uses a non-stub implementation when OpenRouter key is present.

## Work Log

### 2026-02-06 - Task List Created

**By:** Codex

**Actions:**
- Consolidated remaining gaps into a single execution checklist.
- Ordered tasks to tackle backend contract issues first, then mobile sync, then service binding.

**Learnings:**
- Plan checkboxes can drift from runtime behavior; targeted follow-up pass is valuable.

### 2026-02-06 - Resolution

**By:** Codex

**Actions:**
- Updated review queue counting so `total_due` is computed before pagination and returned in top-level and `meta`.
- Aligned `ChildProfile` `$fillable` with streak/XP fields already used by progression logic.
- Removed synthetic local pack-progress increments and added a backend pack refresh after successful result submission.
- Added `PrismConceptExtractor` and switched service binding to use it when OpenRouter is configured (fallback to stub otherwise).
- Ran `dart format` on AppState, Flutter tests, and PHP syntax validation on changed backend files.

**Learnings:**
- Using backend-derived mastery consistently avoids UI drift introduced by local heuristics.
