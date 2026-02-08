---
status: pending
priority: p3
issue_id: "032"
tags: [code-review, backend, testing]
dependencies: []
---

# Create SchoolAssessmentFactory for Tests

Tests create SchoolAssessment records inline without a factory, inconsistent with other model tests.

## Problem Statement

`SchoolAssessmentTest` creates test data using raw array inserts instead of a dedicated factory. Other models (ChildProfile, Document, MasteryProfile) have factories. This makes tests more verbose and harder to maintain when the schema changes.

## Findings

- `backend/tests/Feature/SchoolAssessmentTest.php` uses inline data creation.
- `backend/database/factories/` has factories for other models but not SchoolAssessment.

## Proposed Solutions

### Option 1: Create Factory

**Approach:** Add `SchoolAssessmentFactory` with sensible defaults.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- New: `backend/database/factories/SchoolAssessmentFactory.php`
- `backend/tests/Feature/SchoolAssessmentTest.php`

## Acceptance Criteria

- [ ] SchoolAssessmentFactory exists with defaults
- [ ] Tests refactored to use factory

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)
