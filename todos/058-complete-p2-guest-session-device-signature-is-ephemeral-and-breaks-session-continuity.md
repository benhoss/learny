---
status: complete
priority: p2
issue_id: "058"
tags: [code-review, onboarding, mobile, reliability]
dependencies: []
---

# Guest Session Device Signature Is Ephemeral and Breaks Session Continuity

Guest session creation currently uses a random per-run device signature, which prevents stable guest session reuse across app restarts.

## Problem Statement

Guest continuity depends on stable device/session identity. Randomized signatures generate new guest sessions repeatedly, reducing linkage reliability and producing fragmented analytics.

## Findings

- Device signature is generated from timestamp + random value (`mobile/learny_app/lib/state/app_state.dart:1666`).
- Backend deduplicates guest sessions by signature hash (`backend/app/Http/Controllers/Api/GuestSessionController.php:32`).
- Because signature is ephemeral, dedupe does not preserve continuity in normal app relaunch scenarios.

## Proposed Solutions

### Option 1: Persist Stable Device Installation ID

**Approach:** Generate installation ID once and store it in secure/local storage; reuse for guest session creation.

**Pros:**
- Stable guest continuity.
- Minimal backend change.

**Cons:**
- Requires storage handling across platforms.

**Effort:** Small

**Risk:** Low

---

### Option 2: Server-Issued Guest Session Token

**Approach:** Create once and store server-issued `guest_session_id` token client-side; refresh only on explicit reset.

**Pros:**
- Explicit lifecycle management.
- Better revocation semantics.

**Cons:**
- More state handling and migration logic.

**Effort:** Medium

**Risk:** Low

## Recommended Action

To be filled during triage.

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/state/app_state.dart:1666`
- `backend/app/Http/Controllers/Api/GuestSessionController.php:25`

**Related components:**
- Guest linking migration reliability
- Scan-first analytics cohort integrity

**Database changes (if any):**
- None expected.

## Resources

- **PRD:** `specs/scan_first_onboarding_spec.md`

## Acceptance Criteria

- [ ] Guest session is stable across app restarts on same install.
- [ ] Session reset occurs only when explicitly intended.
- [ ] Guest linking succeeds after restart scenarios in tests.

## Work Log

### 2026-02-14 - Review Discovery

**By:** Codex

**Actions:**
- Compared mobile signature generation strategy with backend dedupe keying.
- Confirmed signatures are non-stable by design.

**Learnings:**
- Current implementation favors immediate progress but loses continuity guarantees.

## Notes

- Marked P2 due reliability and measurement impact.

### 2026-02-14 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Ran Flutter analyze/tests and backend PHP syntax checks.
- Verified touched paths compile and key onboarding tests pass.

**Learnings:**
- Guest onboarding flow requires stable session identity + telemetry fallback to preserve funnel integrity.
