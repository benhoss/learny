---
status: complete
priority: p1
issue_id: "048"
tags: [code-review, compliance, onboarding, mobile, backend]
dependencies: []
---

# Age-gate and consent policy are defined but not enforced in onboarding flow

## Problem Statement

The implementation introduces a market policy endpoint, but no client or server path enforces consent-age gating before full activation. This creates a compliance gap versus onboarding PRD safety requirements.

## Findings

- Policy endpoint exists and returns `consent_age` and `requires_verified_parent_consent`: `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php:31`.
- Mobile client has `onboardingPolicy()` API wrapper but it is never used in onboarding state/screen logic: `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart:17`.
- Child flow completes onboarding without any policy gate or verified parent consent check path in onboarding screens/state (`welcome`, `how_it_works`, `create_profile`, `consent`, `plan`).

## Proposed Solutions

### Option 1: Enforce policy in mobile onboarding state machine (recommended)

**Approach:** Fetch policy before child completion, evaluate age bracket against market consent age, and block completion until parent verification flow is completed when required.

**Pros:**
- Fastest path to PRD alignment.
- Keeps UX logic centralized in onboarding state machine.

**Cons:**
- Trusts client behavior unless paired with server guard.

**Effort:** Medium

**Risk:** Medium

---

### Option 2: Server-side enforcement on onboarding completion API

**Approach:** Add backend completion endpoint that validates consent prerequisites before setting `completed_at`.

**Pros:**
- Strong compliance enforcement at data boundary.

**Cons:**
- Requires client/server flow updates.

**Effort:** Medium

**Risk:** Low

---

### Option 3: Hybrid guard (client UX + backend hard stop)

**Approach:** Implement both client gating and server verification requirement.

**Pros:**
- Best legal/compliance posture.

**Cons:**
- Largest implementation scope.

**Effort:** Large

**Risk:** Low

## Recommended Action


## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/onboarding/*.dart`

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/specs/onboarding_implementation_prd.md`

## Acceptance Criteria

- [ ] Child completion path evaluates market consent policy.
- [ ] When policy requires parent consent, onboarding cannot complete without verified parent linkage/approval.
- [ ] Tests cover both legally permitted self-start and blocked markets.
- [ ] Policy usage is visible in telemetry for auditability.

## Work Log

### 2026-02-11 - Review finding captured

**By:** Codex

**Actions:**
- Traced onboarding policy endpoint and client usage.
- Verified no enforcement path in onboarding completion flow.
- Documented compliance risk and remediation options.

**Learnings:**
- Policy data exists but is currently informational only.

## Notes

- This is a merge-blocking compliance gap.

---

### 2026-02-11 - Remediation implemented

**By:** Codex

**Actions:**
- Enforced child onboarding completion consent checks server-side in `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php` when `mark_complete=true`.
- Added market/age-bracket evaluation helper and parent-linked-device requirement.
- Added/updated backend feature coverage in `/Users/benoit/Documents/Projects/P3rform/learny/backend/tests/Feature/OnboardingFlowTest.php` for blocked vs allowed completion.
- Added client-side gating before child completion in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart` and surfaced user feedback in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/onboarding/plan_screen.dart`.

**Learnings:**
- Compliance checks should be enforced server-side, with client checks for UX clarity.
