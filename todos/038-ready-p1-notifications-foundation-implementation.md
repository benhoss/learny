# 038-ready-p1-notifications-foundation-implementation

## Goal
Implement the backend foundation for notifications based on `specs/notifications_and_communications_proposal.md`:
- child-scoped notification APIs
- parent inbox API
- internal trigger/retry/simulate APIs with service auth
- preference precedence (global parent defaults + child override)
- consent-aware policy suppression, dedupe/idempotency, and terminal failure flow

## User Stories
- [x] US1: As a parent, I can define global notification defaults and child-specific overrides, and get an effective merged policy.
- [x] US2: As a parent, I can register and revoke child device tokens securely.
- [x] US3: As a parent, I can view child notification inbox entries and mark them read/opened.
- [x] US4: As a parent, I can view my parent inbox entries scoped only to my account.
- [x] US5: As an internal service, I can trigger notifications with consent-aware policy checks, dedupe, and idempotency keys.
- [x] US6: As an internal service, I can retry failed events with bounded retries and terminal stop behavior for critical campaigns.
- [x] US7: As an engineer, I have indexes and tests that protect correctness for authz, suppression, dedupe/idempotency, and lifecycle transitions.

## Implementation Tasks
- [x] Add notification domain models (`notification_preferences`, `notification_events`, `device_tokens`).
- [x] Add notification config defaults and internal service auth configuration.
- [x] Add internal middleware for signed service token + optional allowlist.
- [x] Implement preference resolver service (global + child + effective merge).
- [x] Implement policy engine service (consent matrix + active-session gate).
- [x] Implement child-scoped public APIs (preferences, devices, inbox, read/open).
- [x] Implement parent inbox API.
- [x] Implement internal APIs (`trigger`, `retry`, `simulate`) with dedupe/idempotency behavior.
- [x] Register routes and middleware aliases.
- [x] Add MongoDB indexes for notification events.
- [x] Add feature tests for user stories and validation scenarios.
- [ ] Run backend tests and fix failures. (blocked locally: PHP 8.1, project requires PHP >=8.2)
