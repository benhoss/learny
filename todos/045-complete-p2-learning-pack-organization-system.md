---
status: complete
priority: p2
issue_id: "045"
tags: [library, ux, metadata, mobile, backend]
dependencies: []
---

# Learning pack organization system (facets + collections)

## Problem Statement
The packs/document library lacks multi-level navigation, filters, and search. Users need auto-classification plus manual organization to quickly find learning materials.

## Findings
- Packs menu currently groups documents by topic only in `mobile/learny_app/lib/screens/home/packs_screen.dart`.
- Library screen is a flat list without filters or search in `mobile/learny_app/lib/screens/documents/library_screen.dart`.
- Backend document scan already produces topic/language suggestions, but subject/topic are conflated on confirm in `backend/app/Http/Controllers/Api/DocumentScanController.php`.

## Proposed Solutions
### Option 1: Hybrid IA (taxonomy + facets + collections + search)
**Approach:** Extend document/pack metadata, add filters + search UI, and add collections and unclassified bucket.
**Pros:** Meets plan requirements and scales with library growth.
**Cons:** Touches backend + mobile, more moving parts.
**Effort:** 2-4 days
**Risk:** Medium

### Option 2: Topic grouping + search only
**Approach:** Keep existing topic grouping, add search field and subject filter.
**Pros:** Faster.
**Cons:** Does not meet plan requirements.
**Effort:** 1 day
**Risk:** Low

## Recommended Action
Implement Option 1 with minimum viable UI for filters/search and metadata fields.

## Technical Details
**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Models/Document.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Models/LearningPack.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentController.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/DocumentScanController.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Jobs/GenerateLearningPackFromDocument.php`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/models/document_item.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/models/learning_pack.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/services/backend_client.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/library_screen.dart`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/review_screen.dart`

## Acceptance Criteria
- [x] Library shows Smart Categories, Collections, Recent uploads sections
- [x] Filters for Subject, Topic, Grade, Language
- [x] Search across documents and packs
- [x] AI classification visible and editable with overrides
- [x] Unclassified bucket shown

## Work Log
### 2026-02-10 - Plan kickoff
**By:** Codex
**Actions:**
- Created todo and identified impacted files

### 2026-02-10 - Implementation pass
**By:** Codex
**Actions:**
- Extended document and learning pack metadata fields in backend models
- Added topic, tags, collections, grade, and override tracking in document creation and scan confirmation
- Propagated metadata into learning pack generation
- Added upload/review inputs for topic, grade, collections, and tags
- Implemented library search, filters, smart categories, collections, recent uploads, and unclassified bucket
