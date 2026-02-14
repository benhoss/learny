---
status: complete
priority: p2
issue_id: "059"
tags: [code-review, analytics, onboarding, ux]
dependencies: []
---

# Link Prompt Shown Event Undercounts Repeat Exposures

The link prompt can intentionally reappear after “Maybe later”, but telemetry de-duplication logic can suppress repeated `link_prompt_shown` events.

## Problem Statement

PRD requires “Maybe later” to remain non-blocking for one additional completed session and then re-prompt. Measuring this behavior needs per-exposure tracking. Current event call omits an instance identifier, so de-duplication may count only first exposure.

## Findings

- Dedup key includes role/step/event/instance (`mobile/learny_app/lib/state/app_state.dart:667`).
- `link_prompt_shown` call from Plan screen does not provide `instanceId` (`mobile/learny_app/lib/screens/onboarding/plan_screen.dart:115`).
- Repeated prompt exposure can be suppressed in analytics for same role/step.

## Proposed Solutions

### Option 1: Pass Prompt Exposure Instance ID

**Approach:** Include `instanceId` based on completed session count or prompt sequence.

**Pros:**
- Accurate prompt exposure analytics.
- Minimal implementation impact.

**Cons:**
- Requires clear convention for instance IDs.

**Effort:** Small

**Risk:** Low

---

### Option 2: Relax Dedup Scope for `link_prompt_shown`

**Approach:** Deduplicate by route visit timestamp window instead of full role/step key for this event.

**Pros:**
- Captures repeated exposures without explicit IDs.

**Cons:**
- Event-specific branching in telemetry layer.

**Effort:** Medium

**Risk:** Medium

## Recommended Action

To be filled during triage.

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/state/app_state.dart:660`
- `mobile/learny_app/lib/screens/onboarding/plan_screen.dart:105`

**Related components:**
- Funnel dashboards for prompt performance
- Copy experiments for link conversion

**Database changes (if any):**
- None expected.

## Resources

- **PRD:** `specs/scan_first_onboarding_spec.md`

## Acceptance Criteria

- [ ] Each user-visible prompt exposure is tracked once.
- [ ] Repeat exposure after “Maybe later” is measurable in analytics.
- [ ] No inflation from duplicate events on same render cycle.

## Work Log

### 2026-02-14 - Review Discovery

**By:** Codex

**Actions:**
- Audited prompt telemetry call sites and dedupe-key strategy.
- Confirmed missing instance identifier on prompt shown events.

**Learnings:**
- Conversion analysis can be biased without exposure-level instrumentation.

## Notes

- Prioritized P2 because it affects optimization and rollout decision quality.

### 2026-02-14 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Ran Flutter analyze/tests and backend PHP syntax checks.
- Verified touched paths compile and key onboarding tests pass.

**Learnings:**
- Guest onboarding flow requires stable session identity + telemetry fallback to preserve funnel integrity.
