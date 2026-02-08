---
status: pending
priority: p2
issue_id: "030"
tags: [code-review, backend, security]
dependencies: []
---

# Restrict FindsOwnedChild Dev Bypass to Local Environment Only

The `FindsOwnedChild` trait dev-mode bypass is active on all non-production environments, not just local.

## Problem Statement

`FindsOwnedChild::findOwnedChild()` checks `config('learny.bound_child_profile_id')` and if set, returns that child directly — bypassing parent-child ownership. This configuration value could be set on staging or testing environments, not just local development. This widens the attack surface for authorization bypass.

## Findings

- `backend/app/Concerns/FindsOwnedChild.php` checks config value without environment guard.
- No `App::environment('local')` check wraps the bypass.
- If `LEARNY_BOUND_CHILD_PROFILE_ID` env var is set on staging, any authenticated user gets that child.

## Proposed Solutions

### Option 1: Add Environment Guard (Recommended)

**Approach:** Wrap the bypass in `if (app()->environment('local') && config('learny.bound_child_profile_id'))`.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Concerns/FindsOwnedChild.php`

## Acceptance Criteria

- [ ] Bypass only active in `local` environment
- [ ] Staging/production ignore `bound_child_profile_id` even if set
- [ ] Test verifies bypass is environment-gated

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Security sentinel flagged broad bypass scope.
