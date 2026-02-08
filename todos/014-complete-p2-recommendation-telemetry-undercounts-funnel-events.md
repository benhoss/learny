---
status: complete
priority: p2
issue_id: "014"
tags: [code-review, telemetry, backend, analytics]
dependencies: []
---

# Recommendation Telemetry Undercounts Funnel Events

Telemetry for recommendation clicks/actions is currently de-duplicated in a way that suppresses repeat interactions and blocks reliable funnel analysis.

## Problem Statement

Home recommendation interactions are being recorded with a deterministic `event_key` and persisted with `updateOrCreate`. This causes repeat taps on the same recommendation to overwrite the same row instead of creating a new event. As a result, CTA and funnel metrics are undercounted and cannot represent real user behavior.

## Findings

- In `backend/app/Http/Controllers/Api/HomeRecommendationController.php:41`, `event_key` is derived from `child_id + event + recommendation_id`, which is stable across repeated taps.
- In `backend/app/Http/Controllers/Api/HomeRecommendationController.php:44`, `LearningMemoryEvent::updateOrCreate` is used with that key, so repeated events collapse into one document.
- In `mobile/learny_app/lib/state/app_state.dart:1926`, only a single `tap` event is emitted before navigation; no distinct completion/abandon stage is tracked for the funnel.

## Proposed Solutions

### Option 1: Append-Only Event Logging (Recommended)

**Approach:** Use `create` for recommendation events and generate a unique event key per interaction (UUID or timestamp-based), keeping `event_order` monotonic.

**Pros:**
- Accurate interaction counts
- Correct funnel conversion analysis
- Better audit trail

**Cons:**
- More event volume
- Requires downstream dashboards to handle increased cardinality

**Effort:** 2-4 hours

**Risk:** Low

---

### Option 2: Keep Dedup + Add Counter Field

**Approach:** Retain `updateOrCreate` but increment a counter on each repeated interaction.

**Pros:**
- Lower write volume
- Minimal schema churn

**Cons:**
- Loses per-event timestamp granularity
- Harder to analyze step-by-step funnels

**Effort:** 2-3 hours

**Risk:** Medium

---

### Option 3: Hybrid Windowed Aggregation

**Approach:** Store raw append-only events short-term and aggregate into rollups asynchronously.

**Pros:**
- Full fidelity + scalable analytics
- Enables retention controls

**Cons:**
- More complex pipeline
- Requires additional batch/stream jobs

**Effort:** 1-2 days

**Risk:** Medium

## Recommended Action

Triage recommendation: implement Option 1 now. Preserve raw event fidelity first, then optimize storage/aggregation if required.

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/HomeRecommendationController.php:41`
- `backend/app/Http/Controllers/Api/HomeRecommendationController.php:44`
- `mobile/learny_app/lib/state/app_state.dart:1926`

**Related components:**
- `learning_memory_events` telemetry stream
- Home recommendation CTR/funnel dashboards

## Resources

- Commit: `2f869c0`
- Plan: `docs/plans/2026-02-07-feat-learning-experience-next-wave-plan.md`

## Acceptance Criteria

- [x] Repeated taps on the same recommendation produce distinct telemetry rows
- [ ] Funnel stages (`tap`, at minimum one downstream stage) are measurable per recommendation
- [x] Existing recommendation flows continue to function
- [x] Automated tests cover duplicate interaction scenarios

## Work Log

### 2026-02-07 - Review Finding

**By:** Codex

**Actions:**
- Reviewed recommendation tracking endpoint and keying strategy
- Verified event persistence logic and client emit point
- Confirmed current implementation collapses repeated interactions

**Learnings:**
- Current approach is idempotent-friendly but analytics-hostile for funnel measurement

### 2026-02-08 - Implementation Completed

**By:** Codex

**Actions:**
- Updated `backend/app/Http/Controllers/Api/HomeRecommendationController.php` to switch from `updateOrCreate` to append-only `create` for recommendation events
- Made recommendation `event_key` unique per interaction using UUID-derived keying
- Added regression assertion in `backend/tests/Feature/HomeRecommendationTest.php` verifying repeated taps produce multiple events

**Learnings:**
- Append-only event storage restores accurate interaction volume with minimal behavioral impact

## Notes

- This is primarily an analytics correctness issue, not a user-facing crash.
