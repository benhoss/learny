---
status: pending
priority: p2
issue_id: "027"
tags: [code-review, mobile, architecture, consistency]
dependencies: []
---

# Add fromJson Factory to Flutter ChildProfile Model

`ChildProfile` model lacks a `fromJson` factory, with deserialization handled inline in `AppState._mapChildProfile()` instead.

## Problem Statement

The `SchoolAssessment` model has a proper `fromJson` factory, following the standard Flutter pattern. But `ChildProfile` relies on `AppState._mapChildProfile()` for deserialization, spreading parsing logic across state management code instead of encapsulating it in the model.

This inconsistency makes maintenance harder and increases the risk of parsing bugs when the profile schema changes.

## Findings

- `mobile/learny_app/lib/models/child_profile.dart` has no `fromJson` factory.
- `mobile/learny_app/lib/models/school_assessment.dart` has a proper `fromJson` factory.
- `mobile/learny_app/lib/state/app_state.dart` `_mapChildProfile()` handles all ChildProfile deserialization inline.

## Proposed Solutions

### Option 1: Add fromJson Factory (Recommended)

**Approach:** Add `ChildProfile.fromJson(Map<String, dynamic> json)` factory and refactor `_mapChildProfile()` to use it.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/models/child_profile.dart`
- `mobile/learny_app/lib/state/app_state.dart` (_mapChildProfile)

## Acceptance Criteria

- [ ] ChildProfile has fromJson factory
- [ ] _mapChildProfile() delegates to ChildProfile.fromJson()
- [ ] All existing references still work
- [ ] flutter analyze passes

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Pattern recognition agent flagged inconsistency with SchoolAssessment model pattern.
