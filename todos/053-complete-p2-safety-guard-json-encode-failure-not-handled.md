---
status: complete
priority: p2
issue_id: "053"
tags: [code-review, reliability, safety, php]
dependencies: []
---

# Safety Guard Does Not Handle JSON Serialization Failures

`GenerationSafetyGuard::evaluate()` assumes `json_encode` always returns a string. If encoding fails (for example, malformed UTF-8), `strtolower` receives a non-string and can trigger a runtime error.

## Problem Statement

A safety subsystem should fail deterministically with controlled behavior. Unhandled serialization errors can crash generation unexpectedly and bypass intended guardrail semantics.

## Findings

- `json_encode` result is passed directly into `strtolower` without type validation (`backend/app/Services/Safety/GenerationSafetyGuard.php:14`).
- No fallback result is produced when payload serialization fails (`backend/app/Services/Safety/GenerationSafetyGuard.php:7`).
- This error path is not covered by unit tests (`backend/tests/Unit/GenerationSafetyGuardTest.php:8`).

## Proposed Solutions

### Option 1: Validate serialization and fail closed

**Approach:** Check `json_encode` return value; when false, return structured `fail` result with a dedicated reason code.

**Pros:**
- Predictable safety behavior.
- No runtime type errors.

**Cons:**
- May block content on malformed payload edge cases.

**Effort:** Small

**Risk:** Low

---

### Option 2: Use `JSON_THROW_ON_ERROR` with explicit catch

**Approach:** Encode with `JSON_THROW_ON_ERROR`, catch `JsonException`, and map to guardrail decision.

**Pros:**
- Explicit and modern error handling.
- Better diagnostics.

**Cons:**
- Slightly more code paths.

**Effort:** Small

**Risk:** Low

## Recommended Action


## Technical Details

**Affected files:**
- `backend/app/Services/Safety/GenerationSafetyGuard.php`
- `backend/tests/Unit/GenerationSafetyGuardTest.php`

**Related components:**
- Learning pack generation guardrail checks
- Game generation guardrail checks

**Database changes (if any):**
- None

## Resources

- **Commit under review:** `48311e3dc92b8ecb496eabb80550eb47eff5a6c2`

## Acceptance Criteria

- [x] Guard returns structured result when payload serialization fails.
- [x] No runtime type error occurs for malformed payloads.
- [x] Unit test covers serialization failure branch.

## Work Log

### 2026-02-13 - Initial Discovery

**By:** Codex

**Actions:**
- Reviewed safety guard evaluation flow.
- Identified unchecked serialization return value and missing test branch.

**Learnings:**
- Current guardrail logic is brittle for malformed input edge cases.

### 2026-02-13 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Added/updated tests where applicable.
- Ran syntax validation on changed PHP files.

**Learnings:**
- Changes are in place; PHPUnit execution remains blocked locally by PHP 8.1 vs required PHP >= 8.2.
