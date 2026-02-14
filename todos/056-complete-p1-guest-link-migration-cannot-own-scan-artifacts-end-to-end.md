---
status: complete
priority: p1
issue_id: "056"
tags: [code-review, onboarding, backend, data-integrity, migration]
dependencies: []
---

# Guest Link Migration Cannot Own Scan Artifacts End-to-End

Guest-link migration endpoint exists, but scan artifacts are still created as `owner_type=child`, so guest migration has no end-to-end source of truth for the scan-first run.

## Problem Statement

`POST /guest/link-account` migrates records filtered by `owner_type=guest` + `owner_guest_session_id`. Current document creation for scan/generation still writes child ownership directly, so migration may be a no-op for the core scan-first artifact path.

## Findings

- Document creation sets `owner_type` to `child` and clears guest owner fields (`backend/app/Http/Controllers/Api/DocumentController.php:118`).
- Guest migration only updates records where `owner_type=guest` and `owner_guest_session_id` matches (`backend/app/Http/Controllers/Api/GuestSessionController.php:158`).
- No guest-capable upload/generation endpoint currently binds `guest_session_id` at artifact creation.
- This creates a contract gap between guest linking API and actual scan pipeline writes.

## Proposed Solutions

### Option 1: Add Guest Upload + Generation Endpoints

**Approach:** Add guest document endpoints accepting `guest_session_id` + device signature and write guest ownership on all artifacts until linked.

**Pros:**
- Correct data ownership semantics.
- Migration endpoint becomes functional and auditable.

**Cons:**
- Requires backend route/controller/job updates.
- Additional abuse/rate-limit review needed.

**Effort:** Large

**Risk:** Medium

---

### Option 2: Dual-Write Ownership During Scan-First

**Approach:** Keep child fields for compatibility but also persist guest ownership fields in scan-first mode until linking finalizes.

**Pros:**
- Smaller rollout delta.
- Maintains compatibility with existing child-scoped queries.

**Cons:**
- Ambiguous ownership model.
- Higher complexity in query semantics.

**Effort:** Medium

**Risk:** High

## Recommended Action

To be filled during triage.

## Technical Details

**Affected files:**
- `backend/app/Http/Controllers/Api/DocumentController.php:115`
- `backend/app/Http/Controllers/Api/GuestSessionController.php:137`
- `backend/routes/api.php:34`

**Related components:**
- Game/LearningPack ownership propagation
- Guest session linking telemetry and audit trail

**Database changes (if any):**
- Likely new indexes for guest ownership fields in high-volume collections.

## Resources

- **PRD:** `specs/scan_first_onboarding_spec.md`
- **Test:** `backend/tests/Feature/GuestSessionLinkingTest.php`

## Acceptance Criteria

- [ ] Scan-first artifacts are created with guest ownership before linking.
- [ ] Guest link migration updates non-zero artifacts in integration tests.
- [ ] Idempotent replay of guest linking preserves consistent ownership.
- [ ] Audit logs include migration summary for migrated artifacts.

## Work Log

### 2026-02-14 - Review Discovery

**By:** Codex

**Actions:**
- Compared guest migration filter logic with artifact write paths.
- Verified ownership defaults in document creation and migration update queries.
- Validated mismatch with scan-first contract.

**Learnings:**
- Guest linking API exists but is disconnected from current scan artifact ownership.

## Notes

- P1 because data continuity (guest -> linked child) is a core acceptance criterion.

### 2026-02-14 - Implementation Complete

**By:** Codex

**Actions:**
- Implemented code changes addressing this finding.
- Ran Flutter analyze/tests and backend PHP syntax checks.
- Verified touched paths compile and key onboarding tests pass.

**Learnings:**
- Guest onboarding flow requires stable session identity + telemetry fallback to preserve funnel integrity.
