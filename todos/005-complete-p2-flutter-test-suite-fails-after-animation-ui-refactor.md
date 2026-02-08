---
status: complete
priority: p2
issue_id: "005"
tags: [code-review, mobile, testing, quality]
dependencies: []
---

# Restore Green Flutter Test Baseline

`flutter test` currently fails due golden drift and pending timers introduced by new animated widgets, preventing a reliable CI-quality signal.

## Problem Statement

Recent UI/animation changes broke test stability. Without a passing baseline, regressions are harder to detect and review confidence drops.

## Findings

- Golden snapshot mismatch reported (`7.50%`, `47241px` diff) for `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/test/goldens/game_widgets_golden_test.dart`.
- Pending timer assertion is triggered during widget tests, with stack traces pointing to delayed animation start in `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/widgets/animations/fade_in_slide.dart:52`.
- `flutter analyze` also reports new warnings (unused fields/imports), indicating unfinished cleanup.

## Proposed Solutions

### Option 1: Make Animations Test-Friendly + Update Goldens (Recommended)

**Approach:** Add deterministic test mode hooks (or disable delayed timers in tests), then re-capture intentional goldens.

**Pros:**
- Stable tests with retained production animation behavior.
- Explicitly documents expected visual updates.

**Cons:**
- Requires small framework-level changes in animation widgets.

**Effort:** Medium  
**Risk:** Low

---

### Option 2: Disable Animation Effects In All Tests

**Approach:** Force zero-duration animations through global test wrappers/theme overrides.

**Pros:**
- Fastest route to stop timer-related failures.

**Cons:**
- Less realistic UI behavior under test.
- Can mask animation lifecycle defects.

**Effort:** Small  
**Risk:** Medium

---

### Option 3: Remove Golden Tests Temporarily

**Approach:** Skip/disable failing goldens until UI stabilizes.

**Pros:**
- Immediate pipeline unblocking.

**Cons:**
- Loses visual regression protection.
- Encourages test debt accumulation.

**Effort:** Small  
**Risk:** High

## Recommended Action

Implemented cancellable animation start timers in `FadeInSlide`, removed refactor-introduced unused symbols/imports, updated the game-widget golden baseline, and reran full Flutter tests.

## Technical Details

**Affected files:**
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/widgets/animations/fade_in_slide.dart:52`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/test/goldens/game_widgets_golden_test.dart:1`
- `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/test/widget_test.dart:1`

**Related components:**
- Widget test harness
- Golden test baselines

**Database changes (if any):**
- No

## Resources

- Commands run:
  - `flutter test`
  - `flutter analyze`

## Acceptance Criteria

- [x] `flutter test` passes locally for `mobile/learny_app`
- [x] Golden tests either updated intentionally or stabilized without regressions
- [x] No pending timer assertions in widget tests
- [x] Analyzer warnings introduced by this refactor are resolved or explicitly suppressed

## Work Log

### 2026-02-06 - Initial Discovery

**By:** Codex

**Actions:**
- Executed test suite and captured failures.
- Traced pending timers to `FadeInSlide` delayed start.
- Confirmed golden failures under current snapshots.

**Learnings:**
- New animation primitives need deterministic behavior paths for test environments.

### 2026-02-06 - Completion Pass

**By:** Codex

**Actions:**
- Updated `/Users/benoit/Documents/Projects/P3rform/learny/mobile/learny_app/lib/widgets/animations/fade_in_slide.dart` to use cancellable `Timer` lifecycle.
- Cleaned unused refactor artifacts in quiz/results/pack session/golden files.
- Ran `flutter test --update-goldens test/goldens/game_widgets_golden_test.dart`.
- Ran full `flutter test` and confirmed all tests pass.

**Learnings:**
- Timer cleanup is essential for stable widget tests when delayed animations are introduced.

## Notes

- Important quality gate issue; should be fixed before broad merge.
