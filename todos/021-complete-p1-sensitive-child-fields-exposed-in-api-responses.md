---
status: pending
priority: p1
issue_id: "021"
tags: [code-review, backend, security, privacy]
dependencies: []
---

# Hide Sensitive Child Profile Fields From API Responses

ChildProfile and SchoolAssessment models expose all fields in API responses, including sensitive data like `support_needs`, `gender`, and internal IDs.

## Problem Statement

Neither `ChildProfile` nor `SchoolAssessment` define a `$hidden` property. This means every API response includes all stored fields: `user_id`, `gender`, `gender_self_description`, `support_needs` (disability-related flags), and `teacher_note`. For a children's app handling sensitive accessibility data, this violates data minimization principles (COPPA/GDPR-K).

Additionally, `user_id` and `child_profile_id` appearing in responses leak internal relationship IDs to clients that don't need them.

## Findings

- `backend/app/Models/ChildProfile.php` has no `$hidden` property — all fields serialized.
- `backend/app/Models/SchoolAssessment.php` has no `$hidden` property.
- Controllers return model instances directly or via `toArray()`, exposing everything.
- `support_needs` contains boolean flags like `dyslexia_friendly_mode` and `attention_support` — sensitive accessibility data.

## Proposed Solutions

### Option 1: Add $hidden to Models (Recommended)

**Approach:** Add `$hidden = ['user_id']` to ChildProfile and `$hidden = ['user_id', 'child_profile_id']` to SchoolAssessment. Consider API resources for fine-grained control.

**Pros:**
- Quick fix with immediate security benefit.
- Standard Laravel pattern.

**Cons:**
- `$hidden` is global; if some endpoints need these fields, use API Resources instead.

**Effort:** Small
**Risk:** Low

## Recommended Action

Add `$hidden` to both models for internal relationship IDs. Consider whether `support_needs` should be a separate endpoint rather than always included.

## Technical Details

**Affected files:**
- `backend/app/Models/ChildProfile.php`
- `backend/app/Models/SchoolAssessment.php`

**Related components:**
- All API endpoints returning these models

## Acceptance Criteria

- [ ] Internal IDs (`user_id`, `child_profile_id`) not in API responses
- [ ] Sensitive fields reviewed for data minimization
- [ ] Existing Flutter client still functions (fields it uses remain visible)

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Security sentinel flagged sensitive data exposure.
- Data integrity guardian confirmed no $hidden on either model.
