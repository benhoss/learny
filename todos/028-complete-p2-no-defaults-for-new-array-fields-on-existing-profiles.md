---
status: pending
priority: p2
issue_id: "028"
tags: [code-review, backend, data-integrity]
dependencies: []
---

# Add Default Values for New Array Fields on ChildProfile

Existing ChildProfile documents lack the new array/object fields, causing potential null reference issues when accessed.

## Problem Statement

The ChildProfile model added `learning_style_preferences`, `support_needs`, and `confidence_by_subject` as new fields. Existing documents in MongoDB don't have these fields. Without `$attributes` defaults, accessing these on old profiles returns null instead of empty arrays/objects, requiring null checks everywhere.

## Findings

- `backend/app/Models/ChildProfile.php` defines no `$attributes` defaults for new fields.
- MongoDB documents are schema-less — old documents won't have these fields.
- Any code doing `$profile->learning_style_preferences` on old documents gets null.
- The `$casts` property could help but isn't defined for these fields.

## Proposed Solutions

### Option 1: Add $attributes Defaults (Recommended)

**Approach:** Set `$attributes = ['learning_style_preferences' => [], 'support_needs' => [], 'confidence_by_subject' => []]`.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `backend/app/Models/ChildProfile.php`

## Acceptance Criteria

- [ ] New fields have empty defaults in `$attributes`
- [ ] Existing profiles without these fields return empty arrays
- [ ] No null reference errors on old profiles

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Data integrity guardian flagged missing defaults for schema-less MongoDB documents.
