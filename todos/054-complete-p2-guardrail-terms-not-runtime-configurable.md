---
status: complete
priority: p2
issue_id: "054"
tags: [code-review, safety, operations, configuration]
dependencies: []
---

# Guardrail Blocked Terms Are Hard-Coded Instead of Runtime Configurable

The blocked term list is hard-coded in config and not sourced from environment or data store, which limits emergency response when new harmful patterns appear.

## Problem Statement

Safety policies should be adjustable quickly without code changes. Requiring a deploy to update blocked terms increases exposure window during active incidents.

## Findings

- `blocked_terms` is defined as a static array in config (`backend/config/learny.php:53`).
- `GenerationSafetyGuard` depends directly on this list at runtime (`backend/app/Services/Safety/GenerationSafetyGuard.php:10`).
- No alternate dynamic source (env string, DB policy table, remote config) is wired in this commit.

## Proposed Solutions

### Option 1: Environment-backed blocked terms list

**Approach:** Parse `LEARNY_AI_GUARDRAILS_BLOCKED_TERMS` from env (comma/JSON) with safe defaults.

**Pros:**
- Fast emergency updates without code edits.
- Minimal architecture change.

**Cons:**
- Env-based lists are harder to audit/version at scale.

**Effort:** Small

**Risk:** Low

---

### Option 2: Policy collection/table with versioned terms

**Approach:** Store blocked terms and policy versions in DB with cache and admin workflow.

**Pros:**
- Strong auditability and policy lifecycle support.
- Better alignment with governance requirements.

**Cons:**
- Higher implementation complexity.
- Requires admin/process tooling.

**Effort:** Medium

**Risk:** Medium

## Recommended Action


## Technical Details

**Affected files:**
- `backend/config/learny.php`
- `backend/app/Services/Safety/GenerationSafetyGuard.php`

**Related components:**
- AI guardrail policy management
- Incident response process

**Database changes (if any):**
- Optional if implementing policy persistence

## Resources

- **Commit under review:** `48311e3dc92b8ecb496eabb80550eb47eff5a6c2`
- **Related spec:** `specs/ai_generation_observability_guardrails_spec.md`

## Acceptance Criteria

- [x] Blocked terms can be updated without code changes.
- [x] Effective policy version is visible in guardrail results.
- [x] Operational runbook documents emergency term updates.

## Work Log

### 2026-02-13 - Initial Discovery

**By:** Codex

**Actions:**
- Compared config implementation against operational guardrail expectations.
- Identified static term-list limitation.

**Learnings:**
- Current implementation is adequate for bootstrap but weak for incident response.

### 2026-02-13 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Added/updated tests where applicable.
- Ran syntax validation on changed PHP files.

**Learnings:**
- Changes are in place; PHPUnit execution remains blocked locally by PHP 8.1 vs required PHP >= 8.2.
