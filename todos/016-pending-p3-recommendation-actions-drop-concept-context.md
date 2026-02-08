---
status: pending
priority: p3
issue_id: "016"
tags: [code-review, ux, mobile, recommendations]
dependencies: []
---

# Recommendation Actions Drop Concept Context

Recommendation actions provide `action_payload` concept context, but the mobile action handler routes to generic flows without passing that context forward.

## Problem Statement

For `start_revision` and weak-area/due recommendations, the selected concept is available in payload but not consumed by the app routing logic. Users still land in generic setup instead of a focused session for the recommended concept, weakening actionability.

## Findings

- Backend emits concept context in `backend/app/Services/Memory/MemorySignalProjector.php:39` and `backend/app/Services/Memory/MemorySignalProjector.php:78`.
- Client action handler in `mobile/learny_app/lib/state/app_state.dart:1929` routes `start_revision` directly to `AppRoutes.revisionSetup` with no payload transfer.
- Similar pattern for rescue path does not guarantee recommendation-specific targeting.

## Proposed Solutions

### Option 1: Route with Concept Seed (Recommended)

**Approach:** Extend revision entrypoint to accept optional `conceptKey` and pre-seed session composition with that concept.

**Pros:**
- Recommendation tap has deterministic, relevant outcome
- Improves perceived personalization quality

**Cons:**
- Requires small contract changes in revision start flow

**Effort:** 3-6 hours

**Risk:** Low

---

### Option 2: Preserve Generic Flow but Prefill Setup UI

**Approach:** Keep route unchanged, pass context to setup UI and let user confirm targeted revision.

**Pros:**
- Minimal backend impact
- Keeps user control

**Cons:**
- Extra step before value delivery
- Lower conversion than one-tap launch

**Effort:** 2-4 hours

**Risk:** Low

---

### Option 3: Ignore Payload Context

**Approach:** Keep current behavior.

**Pros:**
- No implementation work

**Cons:**
- Weakens “next best action” promise
- Lower recommendation trust/CTR potential

**Effort:** 0

**Risk:** Medium (product)

## Recommended Action

Triage recommendation: implement Option 1 to preserve one-tap relevance and align with recommendation intent.

## Technical Details

**Affected files:**
- `backend/app/Services/Memory/MemorySignalProjector.php:39`
- `backend/app/Services/Memory/MemorySignalProjector.php:78`
- `mobile/learny_app/lib/state/app_state.dart:1929`

**Related components:**
- Revision setup/session routing
- Recommendation conversion metrics

## Resources

- Commit: `2f869c0`
- Plan: `docs/plans/2026-02-07-feat-learning-experience-next-wave-plan.md`

## Acceptance Criteria

- [ ] Recommendation concept payload reaches revision start logic
- [ ] Revision session includes at least one item for the recommended concept when available
- [ ] CTR-to-completion improves for concept-targeted recommendations

## Work Log

### 2026-02-07 - Review Finding

**By:** Codex

**Actions:**
- Compared recommendation payload produced by projector vs. mobile action routing
- Confirmed concept context is emitted but not used in route handling

**Learnings:**
- Current UX is functional but misses the strongest value of recommendation-specific targeting

## Notes

- This is a product-quality improvement, not a blocker.
