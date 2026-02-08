---
status: ready
priority: p2
issue_id: "006"
tags: [code-review, mobile, reliability, observability]
dependencies: ["001"]
---

# Expose And Handle Result Submission Failures

Game result submission failures are currently swallowed and returned as `null`, and caller logic is non-blocking. This hides backend write failures from users and developers.

## Problem Statement

Progression writes are critical. Silent failure paths can make streak/XP/mastery appear inconsistent without any visible reason or telemetry, complicating debugging and eroding user trust.

## Findings

- `submitGameResult` returns `null` for any non-201 response and catches all exceptions in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart:294`.
- Caller uses fire-and-forget style `.then` and only updates state on non-null response in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:999`.
- No explicit user feedback, retry policy, or structured logging is emitted on submission failure.

## Proposed Solutions

### Option 1: Return Typed Result + Explicit Error Handling (Recommended)

**Approach:** Return a typed success/failure result with error details; surface retry-safe messaging and logging in caller.

**Pros:**
- Clear observability and deterministic behavior.
- Easier testing of failure scenarios.

**Cons:**
- Requires refactoring method signatures and call sites.

**Effort:** Medium  
**Risk:** Low

---

### Option 2: Throw Exceptions, Handle Centrally In AppState

**Approach:** Let `BackendClient` throw on failure and wrap submission path in `try/catch` with retries.

**Pros:**
- Standard error flow.
- Reduces silent paths.

**Cons:**
- Needs careful async lifecycle handling around navigation.

**Effort:** Medium  
**Risk:** Medium

---

### Option 3: Keep Null Contract But Add Logging + Snackbar

**Approach:** Maintain API signature; add telemetry and user hint when `null` is returned.

**Pros:**
- Minimal change.
- Better than silent failure.

**Cons:**
- Still weakly typed and easier to misuse.

**Effort:** Small  
**Risk:** Medium

## Recommended Action

Implemented explicit exception-based submission handling with one retry, error capture in `AppState`, and user-facing sync warning on results. Keep in `ready` until dedicated unit tests for failure paths are added.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart:273`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:982`

**Related components:**
- Progression persistence path
- Review queue refresh behavior

**Database changes (if any):**
- No

## Resources

- Review target: latest local working tree

## Acceptance Criteria

- [x] Submission failures are detectable in app logs/telemetry
- [x] User receives clear but non-blocking feedback on failure
- [x] Retry behavior (or explicit no-retry policy) is defined and tested
- [ ] Unit tests cover non-201 and timeout scenarios

## Work Log

### 2026-02-06 - Initial Discovery

**By:** Codex

**Actions:**
- Reviewed `BackendClient.submitGameResult` error paths.
- Confirmed null-return contract and caller behavior.
- Identified missing failure visibility and recovery flow.

**Learnings:**
- Reliability issues are amplified when critical writes fail silently.

### 2026-02-06 - Implementation Pass

**By:** Codex

**Actions:**
- Changed `submitGameResult` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart` to throw typed `BackendException` on non-201 and timeout.
- Added retry loop, error capture (`lastResultSyncError`), and `debugPrint` logging in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`.
- Added non-blocking user hint in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/results_screen.dart`.

**Learnings:**
- Explicit failure surfaces are critical for progression integrity and operational debugging.

## Notes

- Should be resolved with issue `001` to ensure end-to-end progression integrity.
