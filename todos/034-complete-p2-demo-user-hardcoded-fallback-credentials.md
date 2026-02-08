---
status: pending
priority: p2
issue_id: "034"
tags: [code-review, backend, security]
dependencies: []
---

# Guard Demo User Auto-Creation Against Non-Local Environments

The login endpoint auto-creates a demo user with hardcoded fallback credentials (`parent@example.com` / `password1234`) that are active on any `local` environment.

## Problem Statement

`AuthController::login()` contains a dev-mode feature that auto-creates a demo user when `APP_ENV=local`. The `env()` calls have hardcoded default values, meaning even without `.env` configuration the backdoor works with predictable credentials. Unlike the `FindsOwnedChild` bypass, there is no `RuntimeException` guard in `AppServiceProvider` to prevent this from being active if `APP_ENV` is misconfigured on a reachable instance.

## Findings

- `backend/app/Http/Controllers/Api/AuthController.php` lines 39-54 auto-create a user with fallback credentials.
- `env('DEMO_USER_EMAIL', 'parent@example.com')` and `env('DEMO_USER_PASSWORD', 'password1234')` have hardcoded defaults.
- Only protected by `app()->environment('local')` check — no production guard rail in AppServiceProvider.
- If `APP_ENV=local` is left on a staging or test server exposed to the internet, anyone can authenticate.

## Proposed Solutions

### Option 1: Add Production Guard + Remove Hardcoded Defaults (Recommended)

**Approach:** Add a `RuntimeException` in `AppServiceProvider::boot()` if demo credentials are set in production (matching the `BOUND_CHILD_PROFILE_ID` pattern). Remove the hardcoded fallback values from `env()` calls so credentials must be explicitly configured.

**Pros:**
- Prevents accidental exposure on misconfigured environments.
- Consistent with existing security patterns.

**Cons:**
- Developers must explicitly set demo credentials in `.env`.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/AuthController.php`
- `backend/app/Providers/AppServiceProvider.php`

## Acceptance Criteria

- [ ] `env()` calls have no hardcoded fallback credentials
- [ ] AppServiceProvider throws RuntimeException if demo user env vars are set in production
- [ ] Demo user auto-creation still works in local development with explicit `.env` config

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (security-sentinel agent)

**Actions:**
- Security audit identified hardcoded credentials in AuthController.
- Noted absence of production guard rail unlike FindsOwnedChild pattern.
