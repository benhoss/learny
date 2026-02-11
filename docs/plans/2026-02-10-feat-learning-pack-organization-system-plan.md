---
title: "feat: Learning pack organization system (faceted + AI classification)"
type: feat
date: 2026-02-10
---

# feat: Learning pack organization system (faceted + AI classification)

## Overview
Design a scalable organization system for scanned documents and learning packs that combines AI auto-classification with user-controlled organization, supports multi-level navigation, and delivers fast search and filtering across growing libraries.

This plan supersedes the narrower topic-only grouping in `docs/plans/2026-02-10-feat-topic-organized-document-library-plan.md` by introducing a hybrid information architecture (taxonomy + facets + tags) that supports automatic classification, manual curation, and progressive navigation.

## Problem Statement / Motivation
The current pack organization is too shallow: a single topic list cannot accommodate diverse learning materials, evolving subjects, or different user mental models. Users need a system that lets them reliably find materials quickly, without understanding internal data structures. The product must also support auto-classification for speed, while enabling easy manual correction and multi-level exploration.

## Research Summary (UX + IA)
Key principles to ground the solution:
- Information architecture emphasizes organization, labeling, navigation, and search as core systems that enable findability and intuitive access to content. Use these as the frame for the packs library. Reference: First Monday IA article.
- Faceted classification and faceted search allow multi-dimensional filtering instead of a single hierarchy, enabling flexible discovery across different user mental models. Reference: faceted search overview; faceted classification overview.
- Controlled vocabularies improve consistency and retrieval, but should be paired with user-driven tags to handle novelty and personal organization. References: controlled vocabulary definition; NISO vocabulary control guidance; LOC discussion of controlled vocabulary benefits.
- Document library navigation scales when metadata navigation trees are combined with key filters, plus indexing to keep queries fast. Reference: Microsoft Support metadata navigation guidance; Microsoft Learn metadata navigation programmability tips.

## Proposed Solution
Implement a hybrid organization model for learning packs and documents:

1) **Base structure: controlled taxonomy + facets**
- Maintain a controlled vocabulary for core facets (Subject, Topic, Grade, Language, Document Type, Source, Status).
- Use AI to propose facet values on scan; store confidence and allow overrides.
- Allow manual edits that update the controlled value or add new terms (queued for moderation/normalization).

2) **User overlays: collections and tags**
- Add user-defined collections (manual groupings) that are independent of AI taxonomy, e.g., “Emma Exam Week”, “Homework Week 3”.
- Add freeform tags (lightweight, user-driven) for flexible grouping and later search.

3) **Multi-level navigation (progressive disclosure)**
- Primary navigation entry: Packs → Library.
- Level 1: “Smart Categories” (AI groups by Subject/Topic), “Collections” (user-made), “Recent uploads”.
- Level 2: facet filters panel (subject/topic/grade/language/doc type/status), multi-select filters.
- Level 3: document or pack details, with related items and “More like this” links based on shared facets.

4) **Search + filters**
- Unified search across documents and packs, scoped by facets and collections.
- Results show active filters and allow quick removal.

5) **Quality loop for auto-classification**
- Prompt users to confirm or correct classification at review time (existing review flow).
- Store corrections to improve future AI prompts or rules.

## Technical Considerations
- Data model extensions for `Document` and `LearningPack`:
  - `subject`, `topic`, `grade_level`, `language`, `document_type`, `source`, `scan_status`, `tags`, `collections`, `ai_confidence`, `user_override`.
- Normalization rules for subject/topic to avoid drift and duplicates (e.g., “Math” vs “Mathematics”).
- Indexing for faceted search and filtering (MongoDB indexes on facet fields, tags, collection IDs).
- On mobile, use collapsible filters and compact chips to keep UX clean.

## User Flows (SpecFlow Notes)
- **Happy path**: user scans → AI proposes metadata → user confirms → item appears in Smart Categories + applicable filters.
- **Override path**: user edits subject/topic during review → item appears under corrected category, AI correction stored.
- **Manual curation**: user adds document to a collection → collection appears in “Collections” section.
- **Search path**: user types query → results filter by subject and grade → removes filters via chips.
- **Edge case**: missing metadata → item placed in “Unclassified” bucket with nudges to edit.

## Acceptance Criteria
- [x] Library supports multi-level navigation: Smart Categories, Collections, Recent uploads.
- [x] User can filter by at least 4 facets (Subject, Topic, Grade, Language).
- [x] Search works across documents and packs and respects active filters.
- [x] AI auto-classification is visible, editable, and stored with confidence and overrides.
- [x] Unclassified items are discoverable and editable.
- [ ] Performance remains acceptable with 1,000+ items per user.

## Success Metrics
- Users find a document or pack in ≤ 20 seconds after entering Library.
- ≥ 60% of documents have confirmed or corrected classification within first 24 hours.
- Reduced support feedback on “can’t find my document” issues.

## Dependencies & Risks
- Requires consistent metadata generation in OCR pipeline.
- Classification drift risk if users input many variants; needs normalization workflow.
- Mobile UI density risk; must balance power vs simplicity.

## Implementation Phases
### Phase 1: IA foundations (2–3 weeks)
- Define controlled vocabularies for Subject, Topic, Grade, Language, Document Type.
- Add metadata fields to models and API responses.
- Add normalization rules and initial mapping table.

### Phase 2: UX layer (2–3 weeks)
- Build Library entry with Smart Categories, Collections, Recent uploads.
- Implement facet filter UI and search integration.
- Add “Unclassified” bucket and classification edit in review flow.

### Phase 3: Quality loop + scaling (2 weeks)
- Capture corrections and feed them to AI prompt/rules.
- Add usage analytics on filters, search, and classification edits.

## Alternatives Considered
- Single topic list only: too shallow and brittle for real-world content.
- Full folder tree only: manual-heavy and fails without AI assistance.
- Search-only: users still need navigation and browsing for low-intent discovery.

## References & Research
- First Monday IA article (organization, labeling, navigation, search): https://firstmonday.org/ojs/index.php/fm/article/download/2183/2059
- Faceted search overview: https://en.wikipedia.org/wiki/Faceted_search
- Faceted classification overview: https://en.wikipedia.org/wiki/Faceted_classification
- Controlled vocabulary definition: https://en.wikipedia.org/wiki/Controlled_vocabulary
- NISO vocabulary control standard overview: https://www.niso.org/press-releases/2005/11/niso-releases-new-standard-vocabulary-control
- Library of Congress controlled vocabulary benefits: https://www.loc.gov/catdir/bibcontrol/chan_paper.html
- SharePoint metadata navigation guidance: https://support.microsoft.com/en-us/office/set-up-metadata-navigation-for-a-list-or-library-c222a75d-8b18-44e2-9ed8-7ee4e0d23cfc
- SharePoint metadata navigation tips (programmability/perf): https://learn.microsoft.com/en-us/previous-versions/office/developer/sharepoint-2010/ee559293%28v%3Doffice.14%29

## AI-Era Considerations
- Record prompt variants used for metadata extraction and classification.
- Maintain audit trail for AI-suggested vs user-confirmed metadata.
- Add tests for schema validation and metadata completeness.

## Open Questions
- Which facets are mandatory for first release (Subject, Topic, Grade, Language)?
- Should user collections be private per child profile or shared at family level?
- Do we support multiple topics per document or force a primary topic?
