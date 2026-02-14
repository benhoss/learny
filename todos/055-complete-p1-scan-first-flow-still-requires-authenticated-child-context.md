---
status: complete
priority: p1
issue_id: "055"
tags: [code-review, onboarding, mobile, architecture, compliance]
dependencies: []
---

# Scan-First Flow Still Requires Authenticated Child Context

The scan-first PRD requires first quiz completion without account creation. Current mobile implementation still depends on authenticated backend session and child profile creation before scanning and generation.

## Problem Statement

The scan-first onboarding path is intended to be value-first and guest-capable. In practice, scan upload and generation still go through `_ensureBackendSession()` and authenticated child endpoints, creating identity/setup dependency before first value.

## Findings

- `generateQuizFromBytes` calls `_ensureBackendSession()` before upload (`mobile/learny_app/lib/state/app_state.dart:1429`).
- `generateQuizFromImages` also calls `_ensureBackendSession()` (`mobile/learny_app/lib/state/app_state.dart:1516`).
- `_ensureBackendSession()` auto-login/registers and ensures a child profile exists (`mobile/learny_app/lib/state/app_state.dart:1576`).
- This conflicts with scan-first acceptance criteria that first quiz should be completable without account creation.

## Proposed Solutions

### Option 1: True Guest Pipeline Endpoints

**Approach:** Add guest-capable document and generation endpoints and use them from scan-first UI path.

**Pros:**
- Fully matches PRD behavior.
- Clean separation of guest vs linked ownership.

**Cons:**
- Larger backend+client refactor.
- Requires additional tests and rollout safeguards.

**Effort:** Large

**Risk:** Medium

---

### Option 2: Temporary Guest Adapter Layer

**Approach:** Keep current endpoints but introduce server-side temporary guest actor and avoid explicit user/account creation in client.

**Pros:**
- Faster delivery than full endpoint split.
- Limits mobile churn.

**Cons:**
- Adds technical debt and hidden coupling.
- Harder to reason about long-term.

**Effort:** Medium

**Risk:** Medium

## Recommended Action

To be filled during triage.

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/state/app_state.dart:1401`
- `mobile/learny_app/lib/state/app_state.dart:1488`
- `mobile/learny_app/lib/state/app_state.dart:1576`

**Related components:**
- Backend guest session/linking APIs
- Document upload + generation pipeline

**Database changes (if any):**
- Potentially required for guest-first ownership/indexing hardening.

## Resources

- **PRD:** `specs/scan_first_onboarding_spec.md`
- **Related PRD:** `specs/onboarding_implementation_prd.md`

## Acceptance Criteria

- [ ] First scan-to-quiz completion path runs without account creation/login.
- [ ] No child profile is required prior to first completed quiz in scan-first mode.
- [ ] Existing authenticated path remains functional.
- [ ] Integration tests cover guest scan -> quiz completion.

## Work Log

### 2026-02-14 - Review Discovery

**By:** Codex

**Actions:**
- Reviewed scan-first app state flow and upload/generation code path.
- Traced onboarding role entry into generation pipeline.
- Confirmed auth/session dependency before scan upload.

**Learnings:**
- Current implementation is additive UX only; backend usage is still identity-first at runtime.

## Notes

- Marked P1 because this breaks the core product contract of scan-first onboarding.

### 2026-02-14 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Ran Flutter analyze/tests and backend PHP syntax checks.
- Verified touched paths compile and key onboarding tests pass.

**Learnings:**
- Guest onboarding flow requires stable session identity + telemetry fallback to preserve funnel integrity.
