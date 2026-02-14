---
status: complete
priority: p2
issue_id: "057"
tags: [code-review, analytics, onboarding, mobile]
dependencies: []
---

# Pre-Auth Scan-First Events Are Dropped by Client Telemetry Gate

The client de-duplicates and stores guest events, but silently skips backend telemetry when no auth token exists, causing missing funnel visibility for early scan-first steps.

## Problem Statement

Scan-first requires instrumentation of `scan_started`, `scan_uploaded`, `quiz_generated`, and `quiz_completed`. Current telemetry helper exits early if `backend.token` is null, so initial guest events may never reach backend analytics.

## Findings

- Telemetry gate returns early when unauthenticated (`mobile/learny_app/lib/state/app_state.dart:674`).
- `startScanFirstOnboarding()` tracks guest `scan_started` (`mobile/learny_app/lib/state/app_state.dart:434`) which can execute before token initialization.
- This creates undercount risk in scan-first funnel metrics and A/B analysis.

## Proposed Solutions

### Option 1: Queue Unsent Events Locally and Flush After Session Ready

**Approach:** Persist unsent events and replay once backend session is established.

**Pros:**
- Preserves event completeness.
- Works with intermittent connectivity.

**Cons:**
- Adds event queue complexity.
- Requires duplicate-protection in replay logic.

**Effort:** Medium

**Risk:** Low

---

### Option 2: Send Guest Events to Public Guest Telemetry Endpoint

**Approach:** Route guest events directly to non-auth endpoint with guest session proof.

**Pros:**
- Clean semantics for guest analytics.
- No auth coupling.

**Cons:**
- New endpoint and abuse protections required.

**Effort:** Medium

**Risk:** Medium

## Recommended Action

To be filled during triage.

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/state/app_state.dart:660`
- `mobile/learny_app/lib/state/app_state.dart:416`

**Related components:**
- Onboarding analytics pipeline
- Dashboard queries for scan-first funnel

**Database changes (if any):**
- None expected.

## Resources

- **PRD:** `specs/scan_first_onboarding_spec.md`

## Acceptance Criteria

- [ ] Guest scan-first events are reliably delivered to backend analytics.
- [ ] No duplicate counting after retries/replays.
- [ ] Event delivery behavior is covered in tests.

## Work Log

### 2026-02-14 - Review Discovery

**By:** Codex

**Actions:**
- Reviewed telemetry helper and guest event callsites.
- Confirmed early-return condition suppresses unauthenticated sends.

**Learnings:**
- Local dedupe exists, but not delivery guarantee for pre-auth events.

## Notes

- Prioritized as P2 due analytics integrity impact.

### 2026-02-14 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Ran Flutter analyze/tests and backend PHP syntax checks.
- Verified touched paths compile and key onboarding tests pass.

**Learnings:**
- Guest onboarding flow requires stable session identity + telemetry fallback to preserve funnel integrity.
