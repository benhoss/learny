---
status: pending
priority: p2
issue_id: "026"
tags: [code-review, backend, architecture]
dependencies: []
---

# Move Payload Normalization From ChildProfileController to Model

`ChildProfileController::normalizePayload()` contains business logic (clearing gender_self_description, lowercasing language) that belongs in the model layer.

## Problem Statement

The `normalizePayload()` method in the controller handles data normalization: clearing `gender_self_description` when gender is not `self_describe`, and lowercasing `preferred_language`. This logic is model-invariant and should apply regardless of how the model is updated (API, seeder, job). Placing it in the controller means any other code path that updates ChildProfile would skip normalization.

## Findings

- `backend/app/Http/Controllers/Api/ChildProfileController.php` has `normalizePayload()` method.
- Logic includes: clear gender_self_description conditionally, lowercase preferred_language.
- No mutator or model event handles these normalizations.

## Proposed Solutions

### Option 1: Model Mutators (Recommended)

**Approach:** Add `setPreferredLanguageAttribute()` mutator for lowercasing and a `saving` event to clear gender_self_description when gender changes.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Models/ChildProfile.php`
- `backend/app/Http/Controllers/Api/ChildProfileController.php` (remove normalizePayload)

## Acceptance Criteria

- [ ] Language is always lowercased regardless of update path
- [ ] gender_self_description cleared on non-self_describe gender change
- [ ] Controller normalizePayload() removed
- [ ] Existing tests pass

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Architecture strategist and pattern recognition agents flagged controller-level business logic.
