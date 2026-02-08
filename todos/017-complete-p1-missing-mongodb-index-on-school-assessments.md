---
status: pending
priority: p1
issue_id: "017"
tags: [code-review, backend, database, performance]
dependencies: []
---

# Add MongoDB Index on school_assessments Collection

The `school_assessments` collection has no compound index on `child_profile_id`, causing full collection scans on every list query.

## Problem Statement

`SchoolAssessmentController@index` filters by `child_profile_id` but no index exists to support this query. As the collection grows, every assessment listing triggers a full collection scan, degrading response times linearly with data volume.

Additionally, `TestCase.php` uses `dropCollection()` between tests, which removes any manually created indexes during test runs.

## Findings

- `SchoolAssessmentController@index` queries `SchoolAssessment::where('child_profile_id', ...)` without any supporting index.
- The `SchoolAssessment` model at `backend/app/Models/SchoolAssessment.php` defines no indexes.
- `backend/tests/TestCase.php` drops and recreates collections between tests, so indexes must be recreated via migration or model boot.

## Proposed Solutions

### Option 1: Laravel Migration with Index (Recommended)

**Approach:** Create a migration that adds a compound index `{child_profile_id: 1, assessed_at: -1}` to support both filtering and default chronological ordering.

**Pros:**
- Standard Laravel pattern for index management.
- Survives deployments and is version-controlled.

**Cons:**
- Requires running migration on existing environments.

**Effort:** Small
**Risk:** Low

## Recommended Action

Create a migration adding `{child_profile_id: 1, assessed_at: -1}` compound index on the `school_assessments` collection.

## Technical Details

**Affected files:**
- `backend/app/Models/SchoolAssessment.php`
- New migration file in `backend/database/migrations/`

**Related components:**
- SchoolAssessmentController@index
- Any future trend-line dashboard queries

**Database changes (if any):**
- Add compound index `{child_profile_id: 1, assessed_at: -1}` on `school_assessments`

## Acceptance Criteria

- [ ] Migration creates compound index on `school_assessments`
- [ ] Index covers the primary query pattern (filter by child, sort by date)
- [ ] `explain()` confirms index usage on list query

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Performance and data integrity agents both flagged missing index.
- Confirmed no index definition in model or migrations.

**Learnings:**
- All new MongoDB collections with filtered queries need explicit indexes.
