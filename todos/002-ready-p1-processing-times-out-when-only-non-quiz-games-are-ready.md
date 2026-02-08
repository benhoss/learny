---
status: ready
priority: p1
issue_id: "002"
tags: [code-review, mobile, reliability, generation]
dependencies: []
---

# Avoid False Timeout When Quiz Types Are Missing

The processing loop builds payloads for all ready game types but only considers quiz-like types as valid completion criteria. If only `flashcards`/`matching` are ready, the flow can time out even though content exists.

## Problem Statement

`_pollForPackAndQuiz()` currently treats generation as successful only if one of six quiz-style types is present. This can produce user-visible timeout errors despite having valid ready games, especially when requested game types are constrained.

## Findings

- Ready payloads are collected for all types into `payloadsByType` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:582`.
- Completion selection is restricted to quiz-only types in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:601`.
- If no selected quiz type is found, loop continues until timeout in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:629`.

## Proposed Solutions

### Option 1: Select First Ready Type From Full Queue (Recommended)

**Approach:** Choose initial game from `packGameQueue` (or all ready types), not only quiz subset.

**Pros:**
- Matches dynamic game-type generation behavior.
- Prevents false-negative timeout.

**Cons:**
- Requires minor start-flow adjustments for non-quiz first screens.

**Effort:** Small  
**Risk:** Low

---

### Option 2: Mark Processing As Ready Without Creating `quizSession`

**Approach:** End polling once any ready game exists; defer first screen selection to session start route.

**Pros:**
- Decouples processing from a specific game data model.
- Cleaner separation of responsibilities.

**Cons:**
- Requires screen-level fallback handling for missing quiz session.

**Effort:** Medium  
**Risk:** Medium

---

### Option 3: Enforce Quiz Type At Request Validation

**Approach:** Require backend request to always include at least one quiz type.

**Pros:**
- Keeps current client logic mostly unchanged.

**Cons:**
- Artificial product restriction.
- Blocks pure flashcard/matching workflows.

**Effort:** Small  
**Risk:** High

## Recommended Action

Implemented selection from full `packGameQueue` in generation polling and made processing UI launch the currently selected ready game type. Keep this item in `ready` until runtime validation confirms non-quiz-only generation flows in the deployed environment.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:601`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:629`

**Related components:**
- Document processing status
- Initial game launch logic

**Database changes (if any):**
- No

## Resources

- `/Users/benoit/Documents/Projects/P3rform/learny/docs/plans/2026-02-06-feat-complete-quiz-learning-pipeline-plan.md`

## Acceptance Criteria

- [x] Processing exits successfully when any requested game type is ready
- [x] No timeout occurs when only `flashcards` and/or `matching` are generated
- [x] First playable screen opens correctly for non-quiz-first sessions
- [ ] Existing quiz-first path remains functional

## Work Log

### 2026-02-06 - Initial Discovery

**By:** Codex

**Actions:**
- Traced `_pollForPackAndQuiz()` control flow.
- Verified payload map includes all ready types but selection excludes non-quiz types.
- Confirmed timeout path persists when selected quiz type is absent.

**Learnings:**
- Readiness criteria and launch criteria are currently mismatched.

### 2026-02-06 - Implementation Pass

**By:** Codex

**Actions:**
- Replaced quiz-only `supportedTypes` selection in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart` with queue-based selection across all ready game types.
- Updated `startGameType` to initialize flashcards and matching payload/context instead of returning early.
- Updated `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/documents/processing_screen.dart` to use dynamic ready game type and route.

**Learnings:**
- Polling success criteria should be based on generated content availability, not a specific game subtype.

## Notes

- This issue is critical for reliability and user trust in the generation pipeline.
