---
status: complete
priority: p3
issue_id: "039"
tags: [code-review, flutter, localization, quality]
dependencies: []
---

# Scan Validation Copy Is Hardcoded Instead Of Localized

## Problem Statement

New scan-validation UI/status copy is hardcoded in English and bypasses localization resources, creating inconsistent UX in non-English locales.

## Findings

- Hardcoded status labels in library screen:
  - `Quick scan queued`
  - `Quick scan in progress`
  - `Awaiting validation`
- Hardcoded strings in processing validation card:
  - titles, descriptions, button labels, and validation errors.
- Evidence:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/library_screen.dart:31`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/processing_screen.dart:842`

## Proposed Solutions

### Option 1: Add L10n Keys For New Scan States

**Approach:** Add new localization keys in ARB files and replace hardcoded strings with `L10n.of(context)` lookups.

**Pros:**
- Consistent multilingual UX.
- Aligns with existing app localization architecture.

**Cons:**
- Requires adding and translating keys in all supported locales.

**Effort:** Small  
**Risk:** Low

### Option 2: Temporary Shared Constants

**Approach:** Centralize copy in one constants file until localization regeneration is fixed.

**Pros:**
- Reduces duplication quickly.

**Cons:**
- Still not localized; only a temporary cleanup.

**Effort:** Small  
**Risk:** Low

## Recommended Action

Implemented Option 1:
- Added localization keys for quick-scan pipeline statuses/stages/document labels.
- Replaced hardcoded quick-scan strings in screens with `L10n` lookups.

## Technical Details

- Affected UI:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/library_screen.dart`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/processing_screen.dart`

## Acceptance Criteria

- [x] All new scan-validation UI copy comes from localization keys.
- [x] ARB entries exist for all supported locales.
- [x] No hardcoded English strings remain in new scan-related UI paths.

## Work Log

### 2026-02-09 - Code Review Finding

**By:** Codex

**Actions:**
- Reviewed new scan-validation screens and status mapping copy.
- Identified hardcoded strings bypassing localization.

**Learnings:**
- New UI features should preserve localization parity with existing screens.

### 2026-02-09 - Resolution

**By:** Codex

**Actions:**
- Updated `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/library_screen.dart` and `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/processing_screen.dart` to use localized quick-scan labels.
- Added quick-scan stage/status/doc-status keys to:
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/l10n/app_en.arb`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/l10n/app_fr.arb`
  - `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/l10n/app_nl.arb`
- Regenerated localizations via `flutter gen-l10n`.

**Validation:**
- `flutter analyze` passed on changed UI/state files.

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/library_screen.dart:31`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/processing_screen.dart:842`
