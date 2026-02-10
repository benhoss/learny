---
status: complete
priority: p2
issue_id: "044"
tags: [frontend, flutter, library, packs]
dependencies: []
---

# Topic-organized document library in packs menu

Add a topic-grouped document library section to the Learning Packs menu so users can browse documents by topic as they are scanned.

## Problem Statement

The current library list is flat and lives on a separate screen. Users want to browse documents by topic (Science, French, Math) directly within the Learning Packs menu, using AI-suggested metadata with user overrides.

## Findings

- Packs menu lives in `mobile/learny_app/lib/screens/home/packs_screen.dart`.
- Document library list lives in `mobile/learny_app/lib/screens/documents/library_screen.dart`.
- Document metadata is mapped in `mobile/learny_app/lib/state/app_state.dart` and already includes subject/language.

## Proposed Solutions

### Option 1: Group in PacksScreen (selected)

**Approach:** Build topic groups from `state.documents` inside PacksScreen, sort docs by date, and render a section above the existing packs list. Provide a “View all” link to the Library screen.

**Pros:** Minimal risk, no new state management, quick to ship.

**Cons:** Grouping logic lives in the screen widget.

**Effort:** 2-3 hours

**Risk:** Low

---

### Option 2: Add grouping helper in AppState

**Approach:** Add a derived “documentsByTopic” getter and use it in PacksScreen.

**Pros:** Reusable for other screens.

**Cons:** Slightly more state surface area.

**Effort:** 3-4 hours

**Risk:** Low

## Recommended Action

Implement Option 1 for now, with a small private helper in PacksScreen for grouping + localized labels. Keep library screen as-is.

## Technical Details

**Affected files:**
- `mobile/learny_app/lib/screens/home/packs_screen.dart`
- `mobile/learny_app/lib/l10n/app_en.arb`
- `mobile/learny_app/lib/l10n/app_fr.arb`
- `mobile/learny_app/lib/l10n/app_nl.arb`
- `mobile/learny_app/lib/l10n/generated/app_localizations*.dart`

## Resources

- Plan: `docs/plans/2026-02-10-feat-topic-organized-document-library-plan.md`

## Acceptance Criteria

- [ ] Packs menu shows a “Library by topic” section with grouped document lists.
- [ ] Topic labels derive from subject (Language + language override) with General fallback.
- [ ] Documents are newest-first within each topic.
- [ ] Only topics with documents are shown.
- [ ] User overrides subject before upload and sees it grouped accordingly.

## Work Log

### 2026-02-10 - Implementation

**By:** Codex

**Actions:**
- Added topic grouping section in `mobile/learny_app/lib/screens/home/packs_screen.dart`.
- Included localized subject labels (en/fr/nl) with Language→language override and General fallback.
- Added language to `DocumentItem` and mapping in `mobile/learny_app/lib/state/app_state.dart`.
- Added l10n strings for the new library section and regenerated localizations.
- Updated plan acceptance criteria.

**Learnings:**
- Grouping can stay in PacksScreen for now; can be promoted to AppState later if reused.

## Notes

None.
