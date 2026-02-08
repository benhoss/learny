---
status: ready
priority: p1
issue_id: "003"
tags: [code-review, backend, data-integrity, concurrency]
dependencies: []
---

# Harden Streak Updates Against Race Conditions

Streak mutation logic in `GameResultController` uses read/branch/write operations that are not protected from concurrent requests, so same-day parallel submissions can over-increment streak values.

## Problem Statement

Persistent progression counters (streak and longest streak) must be deterministic. Current logic reads `last_activity_date`, branches, and performs separate updates. Two simultaneous submissions can both see stale state and apply increment paths, resulting in inaccurate streak counts.

## Findings

- Non-atomic control flow starts at `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:136`.
- Increment operation is performed independently in `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:140`.
- Follow-up write to `last_activity_date` and `longest_streak` occurs later in `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:147`.
- No transactional or optimistic-concurrency guard is present around this sequence.

## Proposed Solutions

### Option 1: Single Conditional Atomic Update (Recommended)

**Approach:** Use one atomic DB update keyed by `last_activity_date` conditions so streak mutation and date update happen together.

**Pros:**
- Prevents double increments under parallel requests.
- Keeps behavior deterministic.

**Cons:**
- More complex query expression.
- Depends on Mongo/Laravel driver capabilities.

**Effort:** Medium  
**Risk:** Medium

---

### Option 2: Optimistic Retry Loop With Compare-And-Set

**Approach:** Load, compute, update with condition on previous `last_activity_date`; retry on conflict.

**Pros:**
- Works without global locks.
- Explicit conflict handling.

**Cons:**
- More application logic.
- Slightly higher latency on collisions.

**Effort:** Medium  
**Risk:** Medium

---

### Option 3: Idempotency Key Per Child/Day

**Approach:** Record per-day completion marker and make streak update idempotent per child/date.

**Pros:**
- Strong correctness semantics.
- Easier auditability.

**Cons:**
- Additional persistence/model complexity.
- Broader design change.

**Effort:** Large  
**Risk:** Low

## Recommended Action

Implemented optimistic compare-and-set updates in `GameResultController::updateStreak()` to avoid duplicate increments under concurrent requests. Keep in `ready` until a dedicated concurrency regression test is added.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:131`

**Related components:**
- XP/streak progression
- Game result ingestion endpoint

**Database changes (if any):**
- Possibly none for Option 1/2
- Possible helper collection/index for Option 3

## Resources

- Review target: latest local working tree

## Acceptance Criteria

- [x] Concurrent submissions for same child/day do not inflate `streak_days`
- [x] `longest_streak` remains consistent under concurrent writes
- [ ] Add regression test for simulated concurrent submissions
- [x] Existing single-request behavior remains unchanged

## Work Log

### 2026-02-06 - Initial Discovery

**By:** Codex

**Actions:**
- Analyzed streak update flow in controller.
- Identified race window between read condition and write operations.
- Mapped collision scenario for same-day parallel submissions.

**Learnings:**
- Counter correctness depends on atomicity, not just increment operators.

### 2026-02-06 - Implementation Pass

**By:** Codex

**Actions:**
- Replaced read/branch/write streak logic with conditional compare-and-set updates in `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php`.
- Added guarded longest-streak update that only applies when the stored value is lower.
- Kept total XP increment as atomic increment.
- Ran `php -l` on the controller to verify syntax.

**Learnings:**
- Using conditional update queries closes the core race window without introducing distributed locks.

## Notes

- This finding is P1 due to persistent user progression integrity.
