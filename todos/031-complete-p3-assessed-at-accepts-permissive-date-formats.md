---
status: pending
priority: p3
issue_id: "031"
tags: [code-review, backend, validation]
dependencies: []
---

# Constrain assessed_at Date Format

The `assessed_at` field uses `'date'` validation which accepts many formats (timestamps, relative dates, etc.) instead of a strict ISO 8601 format.

## Problem Statement

Laravel's `date` validation rule accepts any value that `strtotime()` can parse, including strings like "yesterday" or "next week". For a school assessment date, a strict `date_format:Y-m-d` or ISO 8601 constraint would prevent ambiguous or nonsensical inputs.

## Findings

- `backend/app/Http/Controllers/Api/SchoolAssessmentController.php` uses `'assessed_at' => 'required|date'`.
- `strtotime()` accepts relative date strings and various formats.

## Proposed Solutions

### Option 1: Use date_format Rule

**Approach:** Change to `'assessed_at' => 'required|date_format:Y-m-d'` or `'date_format:Y-m-d\TH:i:s'`.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/SchoolAssessmentController.php`

## Acceptance Criteria

- [ ] Only ISO date format accepted for assessed_at
- [ ] Relative date strings rejected

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)
