---
status: ready
priority: p1
issue_id: "001"
tags: [code-review, mobile, backend, data-integrity]
dependencies: []
---

# Persist Results For Non-Quiz Games

Results are sent to the backend only from quiz answer handlers. Flashcards and matching sessions can complete without any API submission, so streak/XP/mastery updates are skipped for those game types.

## Problem Statement

The pipeline goal is to persist game outcomes and update learning state. Current mobile flow only submits results in quiz-specific code paths, which means important gameplay data is dropped when the user completes flashcards or matching.

This breaks progression consistency and weakens personalized review quality.

## Findings

- Submission is triggered only in quiz answer methods via `_submitGameResults()` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:978`.
- Flashcards completion navigates forward without any result submission path in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/flashcards_screen.dart:192`.
- Matching completion navigates to results without any result payload generation/submission in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/matching_screen.dart:251`.
- Backend endpoint and mastery/streak logic exist, so missing submissions directly produce partial learning history.

## Proposed Solutions

### Option 1: Unified Game Outcome Model (Recommended)

**Approach:** Add a normalized `GameOutcome` object in `AppState` for all game types, and submit through one common completion path.

**Pros:**
- Eliminates per-screen divergence.
- Enables consistent analytics and retries across all games.

**Cons:**
- Requires moderate refactor across game screens.
- Needs careful migration for existing quiz session behavior.

**Effort:** Medium  
**Risk:** Medium

---

### Option 2: Minimal Patch For Flashcards + Matching

**Approach:** Build lightweight result payloads in `flashcards_screen.dart` and `matching_screen.dart`, then call `backend.submitGameResult` at completion.

**Pros:**
- Fastest path to stop data loss.
- Smaller change footprint.

**Cons:**
- Keeps duplicated completion logic.
- Harder to extend for future game types.

**Effort:** Small  
**Risk:** Low

---

### Option 3: Explicitly Scope Backend Persistence To Quiz Only

**Approach:** Keep current implementation but update product expectations, labels, and copy to state only quiz impacts progression.

**Pros:**
- No technical refactor.
- Clear behavior if intentionally constrained.

**Cons:**
- Loses pedagogical signal from non-quiz games.
- Conflicts with current roadmap intent.

**Effort:** Small  
**Risk:** High

## Recommended Action

Implemented a shared completion flow in `AppState` with dedicated `completeFlashcardsGame` and `completeMatchingGame` paths, and wired both game screens to call it before navigation. Keep this item in `ready` until runtime API verification confirms persisted records for non-quiz sessions.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart:978`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/flashcards_screen.dart:192`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/matching_screen.dart:251`
- `/Users/benoit/Documents/Projects/P3rform/learny/backend/app/Http/Controllers/Api/GameResultController.php:15`

**Related components:**
- Game completion flows
- Mastery/streak/XP backend updates

**Database changes (if any):**
- No schema change required

## Resources

- Review target: latest local uncommitted changes on `main`
- `/Users/benoit/Documents/Projects/P3rform/learny/docs/plans/2026-02-06-feat-complete-quiz-learning-pipeline-plan.md`

## Acceptance Criteria

- [x] Flashcards completion triggers result submission
- [x] Matching completion triggers result submission
- [ ] Backend `game_results` records are created for all played game types
- [ ] Streak/XP/mastery updates occur consistently after any game completion
- [ ] Manual regression check confirms no duplicate submissions

## Work Log

### 2026-02-06 - Initial Discovery

**By:** Codex

**Actions:**
- Reviewed game completion flows and submission entrypoints.
- Confirmed `_submitGameResults()` is quiz-only.
- Traced flashcards/matching completion routes and validated no backend submission path.

**Learnings:**
- Backend progression logic is present; primary gap is mobile completion integration.

### 2026-02-06 - Implementation Pass

**By:** Codex

**Actions:**
- Added `completeFlashcardsGame` and `completeMatchingGame` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`.
- Added unified completion/submission path `_recordAndSubmitGameCompletion`.
- Updated `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/flashcards_screen.dart` and `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/matching_screen.dart` to submit results on completion.
- Ensured pack session starts call `startGameType` for `flashcards` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/packs/pack_session_screen.dart`.

**Learnings:**
- A normalized completion hook simplifies multi-game persistence and future game additions.

## Notes

- This finding is merge-blocking for the "complete learning pipeline" objective.
