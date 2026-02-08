---
status: complete
priority: p2
issue_id: "008"
tags: [code-review, mobile, reliability, backend]
dependencies: ["007"]
---

# Restore Retry For Transient Result Submission Failures

The current submission path performs a single network attempt. On transient timeout/network failures, it immediately falls back locally and never retries, increasing chances of backend drift.

## Problem Statement

Result persistence is core to mastery, streaks, and review scheduling. A one-shot submission strategy is fragile under temporary network turbulence and can leave backend state stale even when a quick retry would succeed.

## Findings

- `submitGameResult` already uses a 10s timeout and throws typed failures in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart:292`.
- `_submitGameResults` currently has a single `try/catch` with no retry loop in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1212`.
- Earlier implementation used one delayed retry; this behavior was removed, reducing resilience against intermittent failures.

## Proposed Solutions

### Option 1: Add One Delayed Retry (Recommended)

**Approach:** Re-introduce a bounded retry loop (`maxAttempts = 2`, short backoff) before falling back locally.

**Pros:**
- High reliability gain for minimal complexity.
- Keeps UX unchanged while improving backend consistency.

**Cons:**
- Slightly longer wait in failure scenarios.

**Effort:** Small  
**Risk:** Low

---

### Option 2: Queue Deferred Sync Jobs

**Approach:** Persist unsent results locally and retry in background when connectivity returns.

**Pros:**
- Strong eventual consistency.
- Better offline/transient support.

**Cons:**
- Larger architectural change.
- Requires queue persistence and deduplication.

**Effort:** Large  
**Risk:** Medium

## Recommended Action

Apply Option 1 now (single retry with backoff), then consider Option 2 when offline mode is in active scope.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:1192`

**Related components:**
- Backend submission reliability
- Review queue freshness

## Acceptance Criteria

- [x] Submission performs a second attempt after transient failure.
- [x] Local fallback is triggered only after retries are exhausted.
- [x] Unit test covers timeout then success-on-retry.
- [x] Unit test covers repeated failure then fallback.

## Work Log

### 2026-02-06 - Review Finding

**By:** Codex

**Actions:**
- Audited error-handling flow from `answer*` completion to backend submission.
- Confirmed immediate fallback on first error with no retry.
- Compared behavior to prior two-attempt pattern.

**Learnings:**
- One bounded retry materially improves data consistency for low implementation cost.

### 2026-02-06 - Resolution

**By:** Codex

**Actions:**
- Reintroduced bounded retry (`2` attempts) in `_submitGameResults` with injectable delay for tests.
- Kept local fallback only after retries are exhausted.
- Added regression test `retries once and succeeds on second submit attempt` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/test/state/app_state_result_submission_test.dart`.

**Learnings:**
- A single bounded retry captures common transient failures without introducing queueing complexity.
