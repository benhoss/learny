---
status: complete
priority: p1
issue_id: "047"
tags: [code-review, security, onboarding, backend, api]
dependencies: []
---

# Link code consume endpoint vulnerable to brute force and abuse

## Problem Statement

The parent-child link code consume endpoint is public and uses a 6-digit code without explicit write-throttling or attempt controls. This exposes child device linking to brute-force and enumeration risk.

## Findings

- The consume route is unauthenticated and outside the authenticated/throttled write block: `/Users/benoit/Documents/Projects/P3rform/learny/backend/routes/api.php:27`.
- Codes are only 6 digits (`100000-999999`) and validated purely by hash lookup with no attempt counter/lockout: `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php:160`, `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php:200`.
- A successful consume links a device immediately, so successful guessing yields persistent access metadata on the child account: `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php:230`.

## Proposed Solutions

### Option 1: Add strict throttle + attempt tracking (recommended)

**Approach:** Place consume endpoint behind dedicated `throttle:api-write` (or stricter custom limiter), track failed attempts per IP/code prefix, and lock token after N failures.

**Pros:**
- Minimal product flow change.
- Significant brute-force resistance.

**Cons:**
- Still based on short numeric codes.

**Effort:** Medium

**Risk:** Low

---

### Option 2: Replace with high-entropy one-time token

**Approach:** Use 24+ char random token/nonce (or signed JWT) for consume API; keep 6-digit code only for local UX display mapped to high-entropy server token.

**Pros:**
- Strong cryptographic resistance.
- Better long-term security posture.

**Cons:**
- More implementation work and migration considerations.

**Effort:** Large

**Risk:** Medium

---

### Option 3: Require authenticated child session before consume

**Approach:** Consume endpoint requires child app auth session plus short code match.

**Pros:**
- Reduces anonymous attack surface.

**Cons:**
- Increases onboarding friction.

**Effort:** Medium

**Risk:** Medium

## Recommended Action


## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/routes/api.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php`

## Resources

- PRD requirement: short-lived single-use linking tokens with safe defaults.

## Acceptance Criteria

- [ ] Consume endpoint has strict rate limiting independent of general API limits.
- [ ] Failed attempts are counted and token is invalidated/locked after threshold.
- [ ] Security tests cover brute-force and replay behavior.
- [ ] Existing happy-path linking still works end-to-end.

## Work Log

### 2026-02-11 - Review finding captured

**By:** Codex

**Actions:**
- Reviewed onboarding API route placement and controller logic.
- Identified unauthenticated consume path plus low-entropy code risk.
- Documented mitigation options and acceptance checks.

**Learnings:**
- Current flow optimizes UX but needs stronger abuse controls.

## Notes

- This is a merge-blocking security concern.

---

### 2026-02-11 - Remediation implemented

**By:** Codex

**Actions:**
- Added explicit write-throttle middleware for consume endpoint in `/Users/benoit/Documents/Projects/P3rform/learny/backend/routes/api.php`.
- Added IP-based rate limiting and token failure lockout in `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php`.
- Added atomic consume lock via cache lock to reduce race/replay risk.
- Extended `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Models/OnboardingLinkToken.php` with `failed_attempts` and `locked_at`.

**Learnings:**
- A mixed strategy (route throttle + app-level limiter + token lockout) materially lowers brute-force risk without changing UX contract.
