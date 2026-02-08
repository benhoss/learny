---
status: pending
priority: p1
issue_id: "022"
tags: [code-review, backend, security, validation]
dependencies: []
---

# Add Size Limit to confidence_by_subject Array Validation

The `confidence_by_subject` array field has no max size constraint, allowing arbitrarily large payloads.

## Problem Statement

`ChildProfileController` validates each item in `confidence_by_subject` (subject string, confidence range 1-5) but does not limit the array length. A malicious client could send thousands of entries, causing excessive storage consumption and slow reads. The `learning_style_preferences` array has a similar issue.

## Findings

- `backend/app/Http/Controllers/Api/ChildProfileController.php` validation rules for `confidence_by_subject` use `'array'` without `'max:N'`.
- Same issue for `learning_style_preferences` — validated as `array` with no size cap.
- Spec says `confidence_by_subject` items are `{ subject, confidence_level }` — realistically bounded to ~20 school subjects.

## Proposed Solutions

### Option 1: Add max:N Validation Rules (Recommended)

**Approach:** Add `'max:30'` to `confidence_by_subject` and `'max:10'` to `learning_style_preferences` validation rules.

**Pros:**
- One-line fix per field.
- Prevents abuse while allowing all realistic inputs.

**Cons:**
- None significant.

**Effort:** Small
**Risk:** Low

## Recommended Action

Add `max:30` to `confidence_by_subject` array rule and `max:10` to `learning_style_preferences`.

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/ChildProfileController.php` (validation rules)

## Acceptance Criteria

- [ ] `confidence_by_subject` rejects arrays with >30 items
- [ ] `learning_style_preferences` rejects arrays with >10 items
- [ ] Test covers oversized array rejection

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Security sentinel and performance oracle flagged unbounded array.
- Confirmed no size limit in validation rules.
