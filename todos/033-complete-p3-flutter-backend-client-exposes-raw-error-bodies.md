---
status: pending
priority: p3
issue_id: "033"
tags: [code-review, mobile, error-handling]
dependencies: []
---

# Sanitize Error Responses in Flutter BackendClient

The BackendClient throws raw HTTP error bodies to callers, potentially exposing internal server details.

## Problem Statement

When API calls fail, the BackendClient includes the raw response body in thrown exceptions. This could leak internal error details, stack traces, or database information to the mobile UI layer. Error messages should be sanitized before surfacing.

## Findings

- `mobile/learny_app/lib/services/backend_client.dart` throws exceptions with raw response bodies.
- No error mapping or sanitization layer exists between HTTP responses and UI.

## Proposed Solutions

### Option 1: Error Wrapper Class

**Approach:** Create a `BackendError` class that maps HTTP status codes to user-friendly messages and strips internal details.

**Effort:** Small
**Risk:** Low

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/services/backend_client.dart`

## Acceptance Criteria

- [ ] Raw server error bodies not surfaced to UI
- [ ] Common HTTP errors mapped to user-friendly messages

## Work Log

### 2026-02-08 - Discovery

**By:** Code Review (multi-agent)
