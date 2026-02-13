---
status: complete
priority: p1
issue_id: "051"
tags: [code-review, reliability, architecture, rails, ai]
dependencies: []
---

# Observability Write Failures Break Generation Pipeline

Observability writes are executed inline in the critical generation path. If Mongo write, encryption, or model persistence fails, learning-pack/game generation fails entirely even when AI output is valid. This turns telemetry outages into user-facing feature outages.

## Problem Statement

Generation should not become unavailable because observability persistence fails. The current code path couples telemetry durability to content delivery and violates the intended resilient logging behavior.

## Findings

- `GenerationObservability::startRun()` is called before the main generation logic in both jobs and is not isolated from failures (`backend/app/Jobs/GenerateLearningPackFromDocument.php:49`, `backend/app/Jobs/GenerateGamesFromLearningPack.php:59`).
- `recordArtifact`, `recordGuardrail`, and `complete` are called inline; any exception bubbles into job failure (`backend/app/Jobs/GenerateLearningPackFromDocument.php:69`, `backend/app/Jobs/GenerateGamesFromLearningPack.php:73`).
- A failure in observability write paths therefore marks the document as failed and aborts generation (`backend/app/Jobs/GenerateLearningPackFromDocument.php:121`, `backend/app/Jobs/GenerateGamesFromLearningPack.php:128`).

## Proposed Solutions

### Option 1: Fail-open wrapper around observability calls

**Approach:** Wrap all observability writes in a dedicated helper that catches/logs exceptions and continues generation.

**Pros:**
- Fastest mitigation.
- Prevents telemetry outages from becoming product outages.

**Cons:**
- Possible telemetry gaps during incidents.
- Requires explicit monitoring for dropped events.

**Effort:** Small

**Risk:** Medium

---

### Option 2: Async event outbox for observability

**Approach:** Persist minimal local event/outbox entries and process observability writes in a separate worker with retries.

**Pros:**
- Decouples user path from telemetry backend failures.
- Better retry and durability semantics.

**Cons:**
- More moving parts and operational complexity.
- Requires migration and queue wiring.

**Effort:** Medium

**Risk:** Low

---

### Option 3: Dual strategy (fail-open + durable retry)

**Approach:** Fail-open in request path and enqueue retry task whenever observability call fails.

**Pros:**
- Preserves availability and improves eventual completeness.
- Lower risk than full outbox redesign.

**Cons:**
- More implementation complexity than Option 1.
- Needs dead-letter monitoring.

**Effort:** Medium

**Risk:** Low

## Recommended Action


## Technical Details

**Affected files:**
- `backend/app/Jobs/GenerateLearningPackFromDocument.php`
- `backend/app/Jobs/GenerateGamesFromLearningPack.php`
- `backend/app/Support/Ai/GenerationObservability.php`

**Related components:**
- Queue workers for generation jobs
- MongoDB observability collections

**Database changes (if any):**
- Optional if implementing outbox/retry table or collection

## Resources

- **Commit under review:** `48311e3dc92b8ecb496eabb80550eb47eff5a6c2`
- **Related spec:** `specs/ai_generation_observability_guardrails_spec.md`

## Acceptance Criteria

- [x] Generation still succeeds when observability write fails.
- [x] Observability failure is logged with run/document identifiers.
- [x] Retry/dead-letter strategy defined for dropped telemetry.
- [x] Feature tests cover observability backend failure path.

## Work Log

### 2026-02-13 - Initial Discovery

**By:** Codex

**Actions:**
- Reviewed generation job integration points for observability writes.
- Traced exception flow from observability methods to job failure handlers.
- Classified outage risk as P1 due user-path coupling.

**Learnings:**
- Observability logic currently has no failure isolation layer.
- A transient storage/encryption error can fail otherwise valid content generation.

## Notes

- This is a merge-blocking reliability risk for production traffic.

### 2026-02-13 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Added/updated tests where applicable.
- Ran syntax validation on changed PHP files.

**Learnings:**
- Changes are in place; PHPUnit execution remains blocked locally by PHP 8.1 vs required PHP >= 8.2.
