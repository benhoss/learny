---
status: pending
priority: p2
issue_id: "023"
tags: [code-review, backend, architecture, consistency]
dependencies: []
---

# Align ChildProfileController With FindsOwnedChild Trait

ChildProfileController uses a private `findOwnedProfile()` method instead of the shared `FindsOwnedChild` trait used by all other child-scoped controllers.

## Problem Statement

The `FindsOwnedChild` trait was introduced to standardize parent-child authorization lookup across controllers. `SchoolAssessmentController` and other controllers use it, but `ChildProfileController` duplicates equivalent logic in its own `findOwnedProfile()` method. This inconsistency makes authorization behavior harder to audit and maintain.

## Findings

- `backend/app/Http/Controllers/Api/ChildProfileController.php` has `findOwnedProfile()` private method.
- `backend/app/Concerns/FindsOwnedChild.php` provides the same functionality as a trait.
- All other child-scoped controllers use the trait consistently.

## Proposed Solutions

### Option 1: Refactor to Use Trait (Recommended)

**Approach:** Replace `findOwnedProfile()` with `use FindsOwnedChild` and call the trait's method.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/ChildProfileController.php`

## Acceptance Criteria

- [ ] ChildProfileController uses `FindsOwnedChild` trait
- [ ] Private `findOwnedProfile()` method removed
- [ ] Existing tests still pass

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Architecture and pattern recognition agents flagged inconsistency.
