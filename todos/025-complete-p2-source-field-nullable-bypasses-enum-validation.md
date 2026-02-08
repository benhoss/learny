---
status: pending
priority: p2
issue_id: "025"
tags: [code-review, backend, validation]
dependencies: []
---

# Fix source Field Validation to Prevent Null Bypass of Enum

The `source` field on SchoolAssessment is validated as `nullable|in:manual,ocr`, allowing null to bypass the enum constraint entirely.

## Problem Statement

The validation rule `'source' => 'nullable|in:manual,ocr'` combined with the model `$attributes` default of `manual` means: if a client sends `source: null`, validation passes and the attribute default may or may not apply depending on how the value is set. This creates ambiguity about what value ends up stored.

## Findings

- `backend/app/Http/Controllers/Api/SchoolAssessmentController.php` has `'source' => 'nullable|in:manual,ocr'`.
- `backend/app/Models/SchoolAssessment.php` has `$attributes = ['source' => 'manual']`.
- Explicitly sending `null` passes validation but may override the model default.

## Proposed Solutions

### Option 1: Use sometimes Instead of nullable (Recommended)

**Approach:** Change to `'source' => 'sometimes|in:manual,ocr'` so the field is optional but when present must be a valid enum value.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/SchoolAssessmentController.php` (validation rules)

## Acceptance Criteria

- [ ] Sending `source: null` is rejected
- [ ] Omitting `source` defaults to `manual`
- [ ] Sending `source: manual` or `source: ocr` accepted

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Data integrity guardian flagged nullable enum bypass.
