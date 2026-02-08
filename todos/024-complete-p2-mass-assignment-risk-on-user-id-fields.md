---
status: pending
priority: p2
issue_id: "024"
tags: [code-review, backend, security]
dependencies: []
---

# Remove user_id and child_profile_id From $fillable

`ChildProfile.$fillable` includes `user_id` and `SchoolAssessment.$fillable` includes both `user_id` and `child_profile_id`, enabling mass assignment of ownership fields.

## Problem Statement

Including ownership/relationship fields in `$fillable` means any request payload that includes `user_id` or `child_profile_id` could reassign record ownership if not explicitly filtered. While current controllers set these fields explicitly, any future controller using `Model::create($request->all())` would inherit this risk.

## Findings

- `backend/app/Models/ChildProfile.php` has `user_id` in `$fillable`.
- `backend/app/Models/SchoolAssessment.php` has `user_id` and `child_profile_id` in `$fillable`.
- Controllers currently set these fields explicitly, but `$fillable` leaves the door open.

## Proposed Solutions

### Option 1: Remove From $fillable, Set Explicitly (Recommended)

**Approach:** Remove ownership fields from `$fillable`. Set them explicitly in controller code (which is already done).

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Models/ChildProfile.php`
- `backend/app/Models/SchoolAssessment.php`

## Acceptance Criteria

- [ ] `user_id` removed from both models' `$fillable`
- [ ] `child_profile_id` removed from SchoolAssessment `$fillable`
- [ ] Controllers still set these fields explicitly
- [ ] Existing tests pass

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Security sentinel flagged mass assignment risk.
