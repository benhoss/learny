---
status: ready
priority: p2
issue_id: "004"
tags: [code-review, mobile, UX, quality]
dependencies: ["001"]
---

# Align Results Metrics With Actual Completed Game Type

The results UI always reads from `quizSession`, but non-quiz game flows (flashcards/matching) do not maintain equivalent score state. This can show stale or zero metrics.

## Problem Statement

Users can finish a game and land on results that do not represent what they just did. In mixed-session flows this can display previous quiz values or empty values, reducing trust in progression feedback.

## Findings

- Results metrics are sourced from `quizSession` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/results_screen.dart:21`.
- Matching flow completes and navigates to results without producing quiz-style session metrics in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/matching_screen.dart:251`.
- Flashcards flow can also terminate at results without score normalization in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/flashcards_screen.dart:192`.

## Proposed Solutions

### Option 1: Introduce Shared `lastGameOutcome` State (Recommended)

**Approach:** Store a normalized outcome object (`gameType`, `correct`, `total`, `xpEarned`, etc.) at completion of any game and render results from it.

**Pros:**
- Accurate results across all game types.
- Cleaner separation between in-game state and summary screen.

**Cons:**
- Requires changes across multiple screens.

**Effort:** Medium  
**Risk:** Low

---

### Option 2: Conditional Results Templates Per Game Type

**Approach:** Render different result cards for flashcards, matching, and quiz, each using game-specific state.

**Pros:**
- Flexible presentation per experience.
- Can tune UX by mode.

**Cons:**
- More UI branching and maintenance.

**Effort:** Medium  
**Risk:** Medium

---

### Option 3: Hide Score Metrics For Non-Quiz Games

**Approach:** If no valid quiz metrics exist, show generic completion copy only.

**Pros:**
- Quick mitigation.
- Avoids incorrect numbers.

**Cons:**
- Reduced feedback quality.
- Does not solve unified progression reporting.

**Effort:** Small  
**Risk:** Medium

## Recommended Action

Implemented a shared `GameOutcome` model in `AppState` and switched `ResultsScreen` to render from `lastGameOutcome` with sync-failure messaging. Keep in `ready` pending manual multi-game UI walkthrough.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/results_screen.dart:21`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/matching_screen.dart:251`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/flashcards_screen.dart:192`

**Related components:**
- Session state model
- Navigation transitions to results

**Database changes (if any):**
- No

## Resources

- Review target: latest local working tree

## Acceptance Criteria

- [x] Results always correspond to the game just completed
- [x] No stale quiz metrics appear after matching/flashcards
- [ ] Manual test confirms consistent output for each game type
- [ ] Unit/widget tests cover non-quiz result rendering

## Work Log

### 2026-02-06 - Initial Discovery

**By:** Codex

**Actions:**
- Reviewed result metric source and navigation paths.
- Verified non-quiz completion paths do not feed equivalent score state.

**Learnings:**
- A normalized cross-game outcome model would simplify future game additions.

### 2026-02-06 - Implementation Pass

**By:** Codex

**Actions:**
- Added `GameOutcome` in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/state/app_state.dart`.
- Recorded completion outcome for quiz/flashcards/matching through `_recordAndSubmitGameCompletion`.
- Updated `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/screens/games/results_screen.dart` to use `lastGameOutcome` and display sync warning text when needed.

**Learnings:**
- Separating gameplay state from summary state prevents stale UI after heterogeneous game flows.

## Notes

- Depends on resolution of issue `001` for complete backend parity.
