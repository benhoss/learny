---
title: "feat: Topic-organized document library in packs menu"
type: feat
date: 2026-02-10
---

# feat: Topic-organized document library in packs menu

## Overview
Add a document library section to the Learning Packs menu that groups documents by topic (Science, French, Math, etc.) as they are scanned. Use AI-suggested metadata as the default, while allowing the user to override subject in the existing review flow. Order documents newest-first within each topic and create topics only from uploaded documents (no pre-generated topic list).

## Problem Statement / Motivation
Parents and learners need a quick way to browse uploaded documents by topic without digging into a flat list. The current Library screen lists documents chronologically and is separate from the Learning Packs tab. Grouping by topic in the Packs menu improves discoverability and keeps the workflow in a single place.

## Proposed Solution
- Add a “Library by Topic” section inside the Packs menu (`PacksScreen`).
- Group documents by a computed topic label derived from document metadata:
  - Primary: `document.subject` (already AI-suggested and user-editable in the review flow).
  - Special case: if subject is “Language” and `document.language` is present, label the group as the language (e.g., French).
  - Fallback: “General”.
- Show each topic group with a header and a list of document cards (newest first).
- Keep the existing Library screen for full management; add a “View all” link to it.

## Technical Considerations
- **Frontend grouping logic**: Implement grouping in `AppState` or a view helper used by `PacksScreen`.
- **Document metadata**: Use current `subject` field (user can override before upload in review screen). If missing, fallback to “General”.
- **Sorting**: Sort documents by `createdAt` descending within each group. Sort groups by the most recent document in the group (newest group first).
- **Localization**: Topic labels should be localized where possible (e.g., “Math” → “Maths” in French) or left as-is if user-entered.

## Acceptance Criteria
- [x] Packs menu shows a “Library by Topic” section with grouped document lists.
- [x] Each group is labeled with the topic derived from document metadata (subject → language for Language subject → General fallback).
- [x] Documents are displayed in newest-first order within each group.
- [x] Groups are created only from existing documents; no empty groups are shown.
- [x] Tapping a document still navigates to the same actions as in the current Library flow (regenerate, details, etc.), or provides a consistent summary card.
- [x] User can override subject during review before upload and see the document appear under the chosen topic.

## Success Metrics
- Users can find a document by topic in ≤2 taps from the Packs menu.
- Reduction in Library screen visits for simple browsing (tracked via UI analytics if available).

## Dependencies & Risks
- **Dependency**: Document metadata must be present (subject/language); fallback needed for older documents.
- **Risk**: Topics may be inconsistent if users enter free-form subjects; consider normalization rules in a later iteration.

## SpecFlow Notes (Manual)
- **Happy path**: user uploads document → AI suggests subject → user confirms → document appears under that topic in Packs menu.
- **Override path**: user edits subject before upload → document appears under edited topic.
- **Missing metadata**: document without subject appears under “General”.
- **Language content**: subject “Language” + language “French” shows under “French”.
- **Multiple docs same topic**: group shows list with newest-first sorting.

## References & Research
- Existing Packs menu: `mobile/learny_app/lib/screens/home/packs_screen.dart`
- Library screen (flat list): `mobile/learny_app/lib/screens/documents/library_screen.dart`
- Document mapping: `mobile/learny_app/lib/state/app_state.dart#L1260`
- Document item model: `mobile/learny_app/lib/models/document_item.dart`
