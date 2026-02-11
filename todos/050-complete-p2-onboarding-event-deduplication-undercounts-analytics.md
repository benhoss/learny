---
status: complete
priority: p2
issue_id: "050"
tags: [code-review, analytics, onboarding, mobile, backend]
dependencies: []
---

# Onboarding analytics dedupe is too coarse and can suppress valid events

## Problem Statement

Onboarding telemetry deduplicates by event name only, which suppresses valid events across roles and repeated step completions. This can materially undercount funnel metrics.

## Findings

- Mobile dedupe uses a single `Set<String>` keyed only by `eventName`: `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:605`.
- Backend dedupe also checks event name only within role state (`completed_events`), preventing multi-instance event capture such as multiple child additions: `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php:115`.
- PRD KPI set depends on event-level funnel counts, making undercounting a product-quality risk.

## Proposed Solutions

### Option 1: Dedupe on `(role, step, event_name)` with optional instance id (recommended)

**Approach:** Replace event-name-only dedupe key with composite key, allowing valid repeated events where expected.

**Pros:**
- Preserves anti-duplicate safety.
- Improves funnel metric fidelity.

**Cons:**
- Requires key migration in persisted state.

**Effort:** Medium

**Risk:** Low

---

### Option 2: Server-only dedupe, client fire-and-forget

**Approach:** Remove client dedupe and let backend decide idempotency using event key hash.

**Pros:**
- Single source of truth.

**Cons:**
- Higher backend request volume.

**Effort:** Medium

**Risk:** Medium

---

### Option 3: Keep current behavior and adjust analytics definitions

**Approach:** Accept one-per-user semantics and redefine metrics accordingly.

**Pros:**
- Minimal engineering change.

**Cons:**
- Loses per-step fidelity and weakens KPI usefulness.

**Effort:** Small

**Risk:** High

## Recommended Action


## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Models/OnboardingState.php`

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/specs/onboarding_implementation_prd.md`

## Acceptance Criteria

- [ ] Event dedupe key includes role+step (and instance id where needed).
- [ ] Adding multiple children records expected analytics events.
- [ ] Integration tests verify duplicate suppression still works for retries/reposts.

## Work Log

### 2026-02-11 - Review finding captured

**By:** Codex

**Actions:**
- Analyzed mobile and backend event idempotency logic.
- Confirmed event-name-only dedupe path in both layers.
- Documented impact on onboarding funnel metrics.

**Learnings:**
- Current design avoids duplicates but also suppresses legitimate events.

---

### 2026-02-11 - Remediation implemented

**By:** Codex

**Actions:**
- Switched client dedupe key from event-name-only to composite key (`role|step|event|instance`) in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`.
- Updated backend event idempotency to dedupe using hashed composite event key (role+step+event+instance_id) in `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/OnboardingController.php`.
- Extended client API contract in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart` to pass `instance_id`.

**Learnings:**
- Event-name-only idempotency is too coarse for onboarding funnels with repeatable sub-steps.
