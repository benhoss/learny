# UX Improvement Backlog — Personalization & Parent Value

This proposal translates the current product vision into five high-impact UX improvements, with a strong focus on personalization, learning pain points, and school results tracking.

## 1) Build a **Personalized Learner Profile 2.0** (age, class, preferences, accommodations)

### Why this matters
The app currently captures profile basics but misses core personalization signals that can adapt pedagogy and communication.

### Current gap observed
- Child onboarding UI asks only for profile name and avatar.
- Mobile `ChildProfile` model stores only `id`, `name`, and `gradeLabel`.
- Backend supports `grade_level` and `birth_year`, but there is no structured model for learning preferences, accommodations, or confidence by subject.

### Impact on user experience
- Better content tone and difficulty matching by age/class.
- Reduced frustration through adaptive scaffolding (hints, simpler steps, pacing).
- Better parent trust: recommendations feel specific to their child.

### Implementation outline
- Extend profile fields with:
  - `age` (derived from `birth_year`), `school_class`, `preferred_language`
  - optional `gender` (strictly optional), `learning_style_preferences`
  - `support_needs` (attention span, dyslexia-friendly mode, etc.)
  - `confidence_by_subject` baseline (self-reported)
- Add an onboarding step with clear privacy controls and skip options.
- Use profile signals in recommendation ranking and game generation prompts.

### Success KPI
- +15% session completion in first 2 weeks after onboarding.
- +10% D30 retention for profiles with completed personalization.

---

## 2) Add a **School Results Hub** (grades, tests, trend lines)

### Why this matters
Parents need progress that maps to school outcomes, not only in-app game scores.

### Current gap observed
- The system tracks game outcomes and mastery but has no dedicated model for school assessments.
- Parent dashboard flow exists but remains mostly placeholder-level and action-link driven.

### Impact on user experience
- Parents can connect app usage to real school performance.
- Children and parents can set concrete goals per subject/test period.
- Stronger motivation: "this week’s practice improved next dictation/math test".

### Implementation outline
- Add `school_assessments` domain:
  - fields: `subject`, `assessment_type`, `score`, `max_score`, `grade`, `date`, `teacher_note`, `source` (manual/ocr)
- Enable input methods:
  - manual entry (fast form)
  - optional OCR extraction from report cards/tests
- Show trend views:
  - by subject (last 8–12 weeks)
  - correlation with mastery and practice frequency

### Success KPI
- 60% of active parents enter at least one assessment/month.
- +20% parent weekly dashboard visits.

---

## 3) Launch a **Pain Point Radar** (weak concept detection + root-cause insights)

### Why this matters
Current progress summaries are useful but too aggregate to guide daily interventions.

### Current gap observed
- Progress API returns aggregate values (`total_concepts`, `mastered_concepts`, `average_mastery`) but not explicit root-cause clusters.
- Existing parent actions include weak areas, but the guidance loop can be made more prescriptive and immediate.

### Impact on user experience
- Parents quickly see "why" a child is blocked.
- Children get targeted micro-missions instead of generic practice.
- Faster improvement on test-relevant concepts.

### Implementation outline
- Derive weak-area clusters from:
  - low mastery concepts
  - repeated error patterns
  - slow response/abandonment signals
- Add intervention cards:
  - "Confuses fraction comparison" → 3-minute mission + tip for parent explanation
- Add confidence meter by topic and test-readiness indicator.

### Success KPI
- -25% repeated mistakes on top-3 weak concepts over 4 weeks.

---

## 4) Create a **Personalized Revision Planner** (smart schedule before tests)

### Why this matters
The product promise includes short sessions and revision support, but planning should become calendar-aware and outcome-driven.

### Current gap observed
- Revision sessions exist, but school deadlines/tests are not first-class scheduling entities.
- Recommendations can become much stronger when linked with upcoming assessments.

### Impact on user experience
- Less last-minute cramming.
- Better daily consistency through small planned sessions.
- Parents get proactive alerts, not reactive summaries.

### Implementation outline
- Add "Upcoming Tests" timeline in parent + child views.
- Auto-generate revision plans based on:
  - exam date proximity
  - mastery deficit by tested concepts
  - available daily time budget
- Push adaptive reminders (lightweight, not spammy).

### Success KPI
- +20% completion of planned revision sessions.
- Improved scores for assessments with planner usage.

---

## 5) Upgrade Parent Dashboard to an **Action Center** (not only reporting)

### Why this matters
Parents need guided next actions, not only status widgets.

### Current gap observed
- Parent dashboard currently presents high-level navigation/actions but limited decision support.
- Existing progress displays focus on metrics; they should translate into concrete "do this now" guidance.

### Impact on user experience
- Faster parent decisions with lower cognitive load.
- Better home-school continuity through guided routines.
- Increased trust and perceived product usefulness.

### Implementation outline
- Replace static dashboard blocks with prioritized action queue:
  - "2 urgent weak concepts"
  - "Math test in 3 days: start plan"
  - "No reading practice in 5 days"
- Add one-tap actions: assign mission, start revision, message child encouragement.
- Include "why recommended" transparency (already aligned with recommendation explainability settings).

### Success KPI
- +30% completion rate for parent-triggered suggested actions.

---

## Recommended rollout order (highest ROI first)
1. Personalized Learner Profile 2.0
2. School Results Hub
3. Pain Point Radar
4. Parent Action Center
5. Personalized Revision Planner

## Notes on sensitive data
- Keep gender optional and clearly explain purpose.
- Separate personalization value from mandatory onboarding.
- Add consent language and easy edit/delete controls for profile and school data.
