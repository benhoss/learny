---
status: pending
priority: p1
issue_id: "019"
tags: [code-review, mobile, bug]
dependencies: []
---

# Fix Variable Shadowing Bug in BackendClient.createChild()

`BackendClient.createChild()` declares `final payload` twice in the same scope, causing a compile error or variable shadowing that drops personalization fields.

## Problem Statement

In `backend_client.dart`, the `createChild()` method first builds a `payload` map with the base child fields (line ~86), then declares a second `final payload` map (line ~114) intended to add personalization fields. This either causes a Dart compile error or shadows the first variable, meaning personalization data is never sent to the backend.

## Findings

- `mobile/learny_app/lib/services/backend_client.dart` `createChild()` method has two `final payload` declarations.
- The second declaration overwrites or shadows the first, so base fields or personalization fields are dropped depending on runtime behavior.
- This means the Personalized Learner Profile 2.0 fields are never sent during child creation.

## Proposed Solutions

### Option 1: Single Mutable Payload Map (Recommended)

**Approach:** Use a single `final payload = <String, dynamic>{}` map, conditionally add personalization fields to it, then send.

**Pros:**
- Simple fix, no architectural change.
- All fields sent in one request.

**Cons:**
- None.

**Effort:** Small
**Risk:** Low

## Recommended Action

Remove the second `final payload` declaration and merge personalization fields into the existing map.

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/services/backend_client.dart` (createChild method, lines ~86-120)

**Related components:**
- Child profile creation flow
- Onboarding personalization step

## Acceptance Criteria

- [ ] Only one `payload` variable in `createChild()`
- [ ] All personalization fields are included in the POST body
- [ ] `flutter analyze` passes without warnings on this file
- [ ] Verified via network inspection that personalization fields reach backend

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)

**Actions:**
- Pattern recognition and simplicity agents flagged duplicate variable declaration.
- Confirmed this prevents personalization data from reaching the backend.
