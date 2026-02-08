---
status: pending
priority: p2
issue_id: "029"
tags: [code-review, mobile, architecture, incomplete]
dependencies: []
---

# Integrate SchoolAssessments Into Flutter AppState

BackendClient has full CRUD for school assessments but AppState has no state management, hydration, or refresh methods for them.

## Problem Statement

The Flutter BackendClient exposes `listSchoolAssessments`, `createSchoolAssessment`, `updateSchoolAssessment`, and `deleteSchoolAssessment`. However, AppState has no corresponding state fields, load methods, or notifier integration. This means the mobile app currently cannot display or manage school assessments through the standard state management flow.

## Findings

- `mobile/learny_app/lib/services/backend_client.dart` has 4 assessment methods.
- `mobile/learny_app/lib/state/app_state.dart` has zero references to school assessments.
- No `List<SchoolAssessment>` state field, no `loadSchoolAssessments()` method, no `notifyListeners()` for assessment changes.

## Proposed Solutions

### Option 1: Add Assessment State Management (Recommended)

**Approach:** Add `List<SchoolAssessment>` field, load/create/update/delete methods, and wire into child selection flow.

**Effort:** Medium
**Risk:** Low

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/state/app_state.dart`
- New or existing screen for assessment UI

## Acceptance Criteria

- [ ] AppState has `schoolAssessments` list field
- [ ] Load method fetches assessments for selected child
- [ ] CRUD operations update state and call notifyListeners()
- [ ] Assessment data available for UI screens

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Architecture strategist flagged incomplete mobile integration.
