---
status: complete
priority: p2
issue_id: "049"
tags: [code-review, onboarding, mobile, reliability]
dependencies: []
---

# Child onboarding path can continue even when profile creation fails

## Problem Statement

Child onboarding proceeds to the first challenge even if child profile creation fails, and no user-visible error is shown. This can leave onboarding data inconsistent and hide backend failures.

## Findings

- Child flow calls `createChildForOnboarding()` and does not validate its return before navigating onward: `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/onboarding/create_profile_screen.dart:35` and `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/onboarding/create_profile_screen.dart:50`.
- `createChildForOnboarding()` catches all exceptions and returns `null` without surfacing failure context: `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:530`.
- The same helper tracks `child_profile_created` under role `parent`, even when called from child flow: `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:520`.

## Proposed Solutions

### Option 1: Block child flow on profile creation failure (recommended)

**Approach:** Return a typed result (`success/error`), show inline error banner/toast, and keep user on profile step until success.

**Pros:**
- Prevents silent data-loss path.
- Improves user trust and debuggability.

**Cons:**
- Slightly more UI logic.

**Effort:** Small

**Risk:** Low

---

### Option 2: Support local draft fallback for child-only mode

**Approach:** If backend creation fails, save local child draft and retry sync later.

**Pros:**
- Preserves frictionless child start.

**Cons:**
- Adds sync complexity and conflict handling.

**Effort:** Medium

**Risk:** Medium

---

### Option 3: Separate child and parent child-creation paths

**Approach:** Split method into `createChildForChildFlow` and `createChildForParentFlow` with distinct telemetry behavior.

**Pros:**
- Cleaner semantics and easier maintenance.

**Cons:**
- More code surface.

**Effort:** Medium

**Risk:** Low

## Recommended Action


## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/onboarding/create_profile_screen.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/specs/onboarding_implementation_prd.md`

## Acceptance Criteria

- [ ] Child profile creation failure is visible to the user and blocks progression.
- [ ] Child and parent creation flows emit role-correct analytics metadata.
- [ ] Tests cover failure and retry behavior for child profile creation.

## Work Log

### 2026-02-11 - Review finding captured

**By:** Codex

**Actions:**
- Reviewed child onboarding step transitions and error handling.
- Verified silent-null return path and missing UX feedback.
- Documented role/event mismatch and remediation options.

**Learnings:**
- Current path optimizes continuity but can hide critical backend failures.

---

### 2026-02-11 - Remediation implemented

**By:** Codex

**Actions:**
- Added failure-aware flow in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/onboarding/create_profile_screen.dart`: onboarding no longer advances when child creation fails.
- Added user-visible error messaging and disabled repeat taps while request is in flight.
- Refined `createChildForOnboarding()` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart` to accept role context and emit role-correct event metadata.

**Learnings:**
- Silent continuation is worse than a brief blocking error in onboarding-critical paths.
