---
status: pending
priority: p1
issue_id: "018"
tags: [code-review, backend, performance, api]
dependencies: []
---

# Add Pagination to SchoolAssessment Index Endpoint

`SchoolAssessmentController@index` returns all assessments for a child with no pagination, risking unbounded response sizes.

## Problem Statement

The `index()` method calls `->get()` which returns all matching documents. A child with hundreds of assessments over a school year would produce increasingly large JSON responses, causing memory pressure on the backend and slow rendering on mobile.

Every other list endpoint in the codebase uses pagination — this is an inconsistency.

## Findings

- `SchoolAssessmentController@index` at `backend/app/Http/Controllers/Api/SchoolAssessmentController.php:20` uses `->get()` instead of `->paginate()`.
- Existing controllers (e.g., DocumentController, LearningPackController) use `->paginate()` consistently.

## Proposed Solutions

### Option 1: Add Standard Pagination (Recommended)

**Approach:** Replace `->get()` with `->paginate(20)` and wrap in standard resource response.

**Pros:**
- Consistent with all other controllers.
- Bounded memory and response size.

**Cons:**
- Mobile client must handle paginated response shape.

**Effort:** Small
**Risk:** Low

## Recommended Action

Replace `->get()` with `->paginate(20)` in `SchoolAssessmentController@index`.

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/SchoolAssessmentController.php:20`
- `mobile/learny_app/lib/services/backend_client.dart` (listSchoolAssessments)

**Related components:**
- Flutter BackendClient.listSchoolAssessments must parse paginated response

## Acceptance Criteria

- [ ] Index endpoint returns paginated response
- [ ] Default page size is consistent with other controllers
- [ ] Flutter client correctly parses paginated assessment response

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Performance and architecture agents flagged unbounded query.
- Confirmed pattern inconsistency with other controllers.
