---
status: complete
priority: p3
issue_id: "043"
tags: [code-review, mobile, ux, localization]
dependencies: []
---

# Surface quick scan failures in library status labels

The library screen only maps quick scan queued/processing and awaiting validation. When quick scan fails, the status collapses to a generic “Failed” label with no specific guidance.

## Problem Statement

Users who encounter a quick scan failure see a generic failure status in the document library. This makes it unclear that the fix is to rescan and revalidate, and it loses the specific context provided in other UI states.

## Findings

- `AppState._statusLabelForDocument` only maps `awaiting_validation`, `quick_scan_queued`, and `quick_scan_processing` stages.
- `LibraryScreen._localizedDocStatus` has no case for `quick_scan_failed`.
- L10n includes `statusQuickScanFailed` but no `docStatusQuickScanFailed` entry, so library cannot display a localized quick scan failure status.
- Locations:
  - `mobile/learny_app/lib/state/app_state.dart:2678-2685`
  - `mobile/learny_app/lib/screens/documents/library_screen.dart:28-39`
  - `mobile/learny_app/lib/l10n/app_en.arb` (missing docStatus key)

## Proposed Solutions

### Option 1: Add quick scan failed status label

**Approach:** Add `docStatusQuickScanFailed` to l10n files, map `quick_scan_failed` in `_statusLabelForDocument`, and display in `LibraryScreen`.

**Pros:**
- Clearer UX
- Localized messaging

**Cons:**
- Requires l10n regeneration

**Effort:** 1-2 hours

**Risk:** Low

---

### Option 2: Reuse generic failed label but add helper text

**Approach:** Keep `failed` label but add a secondary hint when stage is `quick_scan_failed` (e.g., “Tap to rescan”).

**Pros:**
- Minimal l10n change

**Cons:**
- Still less explicit

**Effort:** 1-2 hours

**Risk:** Low

---

### Option 3: Add rescan CTA directly in library item

**Approach:** Only show a rescan CTA or badge when stage is `quick_scan_failed`.

**Pros:**
- Actionable

**Cons:**
- UI change beyond labels

**Effort:** 2-4 hours

**Risk:** Medium

## Recommended Action

**To be filled during triage.**

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/state/app_state.dart:2678-2685`
- `mobile/learny_app/lib/screens/documents/library_screen.dart:28-39`
- `mobile/learny_app/lib/l10n/app_en.arb`
- `mobile/learny_app/lib/l10n/app_fr.arb`
- `mobile/learny_app/lib/l10n/app_nl.arb`

**Related components:**
- Document list UI
- Localization pipeline

**Database changes (if any):**
- Migration needed? No

## Resources

- **UI screen:** Library
- **Related strings:** `statusQuickScanFailed`

## Acceptance Criteria

- [x] Library status label shows a localized quick scan failed state.
- [x] Status mapping includes `quick_scan_failed` stage.
- [x] L10n generation updated and no missing keys.

## Work Log

### 2026-02-10 - Initial Discovery

**By:** Claude Code

**Actions:**
- Reviewed library status mapping for new scan stages
- Identified missing quick scan failed label
- Drafted possible UX improvements

**Learnings:**
- L10n has processing-level quick scan failure copy but no library label

### 2026-02-10 - Implementation

**By:** Claude Code

**Actions:**
- Added `quick_scan_failed` mapping in `mobile/learny_app/lib/state/app_state.dart`
- Added localized status label in `mobile/learny_app/lib/screens/documents/library_screen.dart`
- Added `docStatusQuickScanFailed` to `mobile/learny_app/lib/l10n/app_{en,fr,nl}.arb` and ran `flutter gen-l10n`

**Learnings:**
- Library status now distinguishes quick scan failures from general failures

## Notes

- Consider reusing the “Quick scan failed” copy for consistency with processing screen.
