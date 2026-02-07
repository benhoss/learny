---
title: "feat: Learning Experience Next Wave"
type: feat
date: 2026-02-07
---

# ✨ feat: Learning Experience Next Wave

## Overview

This plan operationalizes the five agreed priorities to improve learner outcomes and perceived product quality:

1. Reduce upload-to-play latency.
2. Make revision adaptive and document-aware.
3. Strengthen motivation and progression feedback loops.
4. Expose memory controls and recommendation transparency.
5. Instrument outcomes and tune weekly.

This is a continuation plan after `/Users/benoit/Documents/Projects/P3rform/learny/docs/plans/2026-02-06-feat-smart-revision-upload-speed-memory-loop-plan.md`, focused on the next executable wave.

## Idea Refinement

No brainstorm file was found in `docs/brainstorms/`.

The feature request is explicit enough to proceed without further refinement.

## Local Research Summary

### Repo Findings

- Activity timeline and progression actions exist and now support load-more and guarded actions:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:178`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:246`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:539`
- Activity pagination contract exists in backend and client:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:38`
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:151`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart:362`
- Document regeneration semantics now correctly clear stale filters for generic redo:
  - `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentController.php:157`
- Core memory and recommendation hooks exist in app state:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:320`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1692`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1718`

### Institutional Learnings

No `docs/solutions/` entries were found for this topic.

### Research Decision

Proceeding without fresh external research for this plan. The previous deepened plan already includes current benchmark references, and this plan is execution-focused on already-known gaps.

## Problem Statement / Motivation

The product has improved reliability and activity visibility, but still has major UX and learning-system gaps:

- Upload flow still feels long for many users before first playable value.
- Revision quality can still feel generic when it should be targeted and adaptive.
- Motivation cues exist but are not yet tied to personalized “next best action” mechanics.
- Memory-driven recommendations need user trust controls and explainability surfaces.
- Outcome tuning is constrained without explicit metric baselines, experiments, and alerting.

## Proposed Solution

Run a coordinated “next wave” in five tracks, with strict rollout gates:

1. Fast-start processing and first-playable delivery.
2. Adaptive revision composition v2.
3. Motivation loop upgrades in progress/home surfaces.
4. Memory governance and recommendation explainability.
5. Measurement + weekly optimization cadence.

## Technical Considerations

- Architecture impacts:
  - Add first-playable readiness as a distinct contract in document/game APIs.
  - Add revision composer ranking inputs (mistakes, due queue, recency, unseen).
  - Add memory preference and explainability endpoints.
- Performance implications:
  - Queue-lane isolation and stage telemetry must be explicit to improve TTFQ.
  - Pagination and projection recompute must avoid N+1 and full-table scans.
- Security and privacy:
  - Memory controls require authenticated child ownership checks and auditable mutations.
  - Explainability metadata must avoid exposing private model internals or sensitive source text.

## SpecFlow Analysis

### Primary Flow

1. Parent captures/uploads content.
2. App shows transfer progress + processing stage.
3. Child can start first available game immediately when ready.
4. Game outcomes update memory signals.
5. Home/progress show momentum and next-best-action prompts.
6. Revision session is assembled from due + weak + recent doc concepts.
7. Recommendation includes “why this was suggested.”
8. Parent can pause/clear scope of memory personalization.

### Edge Cases

- Partial generation (only one game type ready).
- Low-confidence metadata suggestions.
- Revision queue empty for new users.
- Burst taps or duplicate submissions.
- Memory controls toggled mid-session.
- Drift between event writes and derived recommendation state.

## Technical Approach

### Architecture

- Keep `learning_memory_events` as source-of-truth writes.
- Maintain sync incremental projection for freshness.
- Run nightly reconciliation for drift correction.
- Expose recommendation explainability and memory controls through stable API contracts.

### Implementation Phases

#### Phase 1: Fast-Start Upload to First Playable

- Backend:
  - Add explicit first-playable fields (`first_playable_game_type`, `first_playable_at`, `ready_game_types`).
  - Isolate queue lanes (`ocr`, `concepts`, `pack`, `games`) and persist stage timing.
- Mobile:
  - Show transfer and processing as separate progress tracks.
  - Auto-surface “Play now” when first game type is ready.
- Quality:
  - Add stage transition tests and partial-ready regression tests.

#### Phase 2: Adaptive Revision Composer v2

- Backend:
  - Rank concepts by weighted score: due status + recent mistakes + recency decay + unseen coverage.
  - Return explainability for each revision item (`reasons`, `source_document`, `confidence`).
- Mobile:
  - Display adaptive session summary before start.
  - Offer “quick retry weak concepts” and “new from latest doc” variants.
- Quality:
  - Add deterministic ranking tests and idempotent session submission tests.

#### Phase 3: Motivation and Progression Loop

- Product/UI:
  - Add momentum panels (trend, XP velocity, mastery delta).
  - Add one-tap next action cards (“Review 3 weak concepts now”).
  - Add streak rescue logic (fallback 2-minute recovery session).
- Data:
  - Define engagement event taxonomy (`cta_shown`, `cta_clicked`, `cta_completed`).
- Quality:
  - Add UI and state tests for action routing and failure handling.

#### Phase 4: Memory Controls and Explainability

- Backend API:
  - `GET /v1/children/{child}/memory/preferences`
  - `PUT /v1/children/{child}/memory/preferences`
  - `POST /v1/children/{child}/memory/clear-scope`
  - Extend recommendations response with `why` metadata.
- Mobile:
  - Add controls: pause personalization, clear memory scope, view recommendation rationale.
- Governance:
  - Add policy copy and consent/visibility text in settings and recommendation surfaces.

#### Phase 5: Metrics and Weekly Optimization

- Baselines:
  - TTFQ, upload abandonment, revision reuse, recommendation CTR, 7-day concept retention proxy.
- Ops:
  - Add dashboards and alerts for queue latency, stage failure rates, and projection drift.
- Process:
  - Weekly review loop with threshold-based adjustments for ranking weights and nudges.

## Alternative Approaches Considered

### Option A: Keep Iterating UI Only

Pros:
- Low engineering risk.

Cons:
- Does not improve adaptation quality or recommendation trust foundations.

Decision: Rejected.

### Option B: Full Scheduler Rewrite First

Pros:
- Long-term learning optimization potential.

Cons:
- Delays near-term UX and latency wins.

Decision: Deferred until wave completion metrics stabilize.

## Acceptance Criteria

### Functional Requirements

- [x] Child can start at least one game before full pipeline completion in partial-ready scenarios.
- [x] Revision sessions are adaptively composed from due + weak + recent document signals.
- [ ] Progress/home surfaces expose actionable next steps tied to real learner state.
- [ ] Parent can pause personalization, clear memory scope, and inspect recommendation rationale.
- [ ] Activity and motivation surfaces remain robust under repeated actions and network failures.

### Non-Functional Requirements

- [ ] Median TTFQ improved by at least 30% vs current baseline.
- [ ] P95 upload-to-first-playable improved by at least 20%.
- [ ] Recommendation CTR improved by at least 12% without increased opt-out.
- [ ] Projection drift between events and derived recommendation state remains below 0.5%.
- [ ] No regression in result idempotency and streak/xp consistency.

### Quality Gates

- [ ] Backend tests for stage transitions, first-playable semantics, adaptive revision ranking.
- [ ] Flutter tests for progress CTA routing, memory controls, and recommendation explainability views.
- [ ] Contract tests for pagination, recommendation `why`, and memory preference endpoints.
- [ ] End-to-end smoke flow: upload -> play first-ready -> complete -> revise -> accept recommendation.

## Success Metrics

- `TTFQ_median`
- `first_playable_p95_seconds`
- `upload_abandonment_rate`
- `revision_reuse_rate_7d`
- `recommendation_ctr`
- `recommendation_completion_rate`
- `memory_control_usage_rate`
- `projection_drift_rate`

## Dependencies & Risks

- Queue infrastructure and worker capacity tuning.
- Stability of projection jobs and monitoring.
- Product copy approval for memory controls and explainability.

Main risks:
- False-positive recommendations reduce trust.
- Over-notification reduces engagement.
- Drift and stale projections create “wrong next action.”

Mitigations:
- Conservative ranking defaults + explainability.
- Notification frequency caps.
- Reconciliation jobs + drift alerts + rollback flag.

## Implementation Task List (Methodical Order)

### Track 1 - First Playable Latency

- [x] Backend first-playable fields and stage timing telemetry.
- [x] Mobile split progress UI + play-now handoff.
- [x] Regression tests for partial-ready flow.

### Track 2 - Adaptive Revision

- [x] Revision ranking v2 + explainability payload.
- [x] Mobile adaptive session variants.
- [ ] Deterministic ranking and submission idempotency tests.

### Track 3 - Motivation Loop

- [ ] Next-best-action cards in home/progress.
- [ ] Streak rescue session entry point.
- [ ] CTA telemetry and funnel instrumentation.

### Track 4 - Memory Governance

- [ ] Memory preferences and clear-scope APIs.
- [ ] Settings UI controls and recommendation “why” dialogs.
- [ ] Contract and policy-copy validation.

### Track 5 - Metrics and Optimization

- [ ] Baseline dashboards and alerts.
- [ ] Weekly tuning ritual and decision log.
- [ ] Feature-flagged ramp with rollback criteria.

## Execution Notes

- 2026-02-07 iteration 1 completed Track 1 implementation in backend and mobile.
- 2026-02-07 iteration 2 completed adaptive revision explainability (backend scoring/reasons + mobile reason/confidence surfaces).
- Flutter validation passed for updated flows and state tests.
- Backend PHPUnit feature tests remain blocked in this environment due missing `MongoDB\\Driver\\Manager`; syntax checks and targeted test additions are in place.

## References & Research

### Internal References

- `/Users/benoit/Documents/Projects/P3rform/learny/docs/plans/2026-02-06-feat-smart-revision-upload-speed-memory-loop-plan.md`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentController.php:136`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:33`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1730`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1765`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/home/progress_screen.dart:178`

### External References (from prior deepened research)

- Laravel Queues: https://laravel.com/docs/12.x/queues
- RAIL: https://web.dev/articles/rail
- Fyxer: https://fyxer.com/how-it-works
- WHOOP Coach: https://www.whoop.com/us/en/thelocker/introducing-whoop-coach/
- OpenAI Memory FAQ: https://help.openai.com/en/articles/8590148-memory-faq
