---
status: pending
priority: p1
issue_id: "020"
tags: [code-review, backend, data-integrity]
dependencies: []
---

# Cascade Delete SchoolAssessments When ChildProfile Is Deleted

Deleting a ChildProfile leaves orphaned SchoolAssessment documents with no parent reference.

## Problem Statement

The `ChildProfile` model has no `hasMany(SchoolAssessment::class)` relationship and no cascade-delete hook. When a parent deletes a child profile, all associated school assessments remain in the database indefinitely. This is both a data integrity issue and a privacy concern (orphaned child data).

Other related collections (documents, mastery_profiles) face the same risk but school_assessments is newly added and should be addressed now.

## Findings

- `backend/app/Models/ChildProfile.php` defines no relationship to SchoolAssessment.
- No `deleting` model event or observer cascades to school_assessments.
- Existing relationships (documents, learningPacks, masteryProfiles) are defined but also lack cascade-delete hooks.

## Proposed Solutions

### Option 1: Model Boot Event Cascade (Recommended)

**Approach:** Add `hasMany(SchoolAssessment::class)` relationship and a `deleting` boot event that deletes related assessments.

**Pros:**
- Consistent with Laravel patterns.
- Ensures cleanup on every deletion path.

**Cons:**
- Must handle large numbers of related documents efficiently.

**Effort:** Small
**Risk:** Low

## Recommended Action

Add `schoolAssessments()` relationship on ChildProfile and cascade deletes in a `deleting` model event.

## Technical Details

**Affected files:**
- `backend/app/Models/ChildProfile.php`
- `backend/app/Models/SchoolAssessment.php` (belongsTo inverse)

**Database changes (if any):**
- No schema change; runtime cascade on delete

## Acceptance Criteria

- [ ] ChildProfile has `schoolAssessments()` hasMany relationship
- [ ] Deleting a ChildProfile also deletes all related SchoolAssessments
- [ ] Test verifies cascade behavior

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Data integrity and architecture agents flagged orphan risk.
- Confirmed no cascade mechanism exists.
