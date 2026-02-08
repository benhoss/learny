# Detailed Specification — Personalized Learner Profile 2.0

## 1. Context
This specification details implementation of UX Improvement #1 from `specs/ux_improvements.md`: **Personalized Learner Profile 2.0 (age, class, preferences, accommodations)**.

The objective is to expand child personalization data beyond basic profile identity so recommendations, learning activities, and parent communication are better adapted to each child.

---

## 2. Product Goals

### 2.1 Primary goals
- Improve learning-session completion by better matching content difficulty and support.
- Reduce frustration by adapting pacing, hinting style, and visual/readability settings.
- Improve parent trust by making recommendations feel specific and explainable.

### 2.2 Non-goals (phase 1)
- No psychometric profiling.
- No diagnosis claims (medical, cognitive, or educational).
- No blocking gate for using the app if personalization is incomplete.

---

## 3. Scope

### 3.1 In scope
- Extended learner profile schema (backend + mobile model updates).
- New onboarding step for personalization (with skip options).
- Parent-accessible profile edit screen after onboarding.
- Personalization signal usage in recommendation ranking and content generation prompts.
- Privacy controls and data minimization copy.
- Event instrumentation for completion and impact analysis.

### 3.2 Out of scope
- School assessment ingestion (covered by School Results Hub workstream).
- Full adaptive curriculum redesign.
- Advanced multilingual localization strategy beyond storing preferred language.

---

## 4. Functional Requirements

### FR-1: Extended child profile fields
Store the following profile fields:

#### Existing / retained
- `name` (string, required)
- `avatar` (string/id, optional)
- `grade_level` (string, optional)
- `birth_year` (integer, optional)

#### New
- `school_class` (string, optional)
  - Example: `CM2`, `6th`, `Year 7`
- `preferred_language` (string, optional, ISO-like code where possible)
  - Example: `fr`, `en`
- `gender` (string, optional)
  - Enum: `female`, `male`, `non_binary`, `prefer_not_to_say`, `self_describe`
  - `gender_self_description` (string, optional, max 50 chars, only if `self_describe`)
- `learning_style_preferences` (array of strings, optional)
  - Enum values: `visual`, `auditory`, `reading_writing`, `hands_on`, `short_bursts`
- `support_needs` (object, optional)
  - `attention_support` (boolean)
  - `dyslexia_friendly_mode` (boolean)
  - `larger_text` (boolean)
  - `reduced_clutter_ui` (boolean)
  - `extra_processing_time` (boolean)
  - `other_notes` (string, optional, max 300 chars)
- `confidence_by_subject` (array, optional)
  - Items: `{ subject: string, confidence_level: integer }`
  - `confidence_level` range: `1..5` (1 = not confident, 5 = very confident)

### FR-2: Derived field behavior
- `age` is not directly stored as a mutable value in persistent profile data.
- `age` is derived dynamically from `birth_year` and current date for display and ranking contexts.
- If `birth_year` is missing, age-dependent logic must gracefully fallback to grade/class signals.

### FR-3: Onboarding personalization step
- Add a post-profile-creation step titled “Help us personalize learning”.
- Every field in this step must be skippable.
- The step includes:
  - clear “Why we ask this” helper copy,
  - “Skip for now” action,
  - “Save and continue” action.
- Incomplete personalization must not prevent access to core app flows.

### FR-4: Profile editability
- Parents can update all personalization fields from settings/profile management at any time.
- Changes are effective for newly generated recommendations and sessions.
- Child-visible settings should only include age-appropriate editable fields as defined by product policy (default: parent-managed).

### FR-5: Recommendation ranking usage
Recommendation service must consume personalization signals with transparent weighting:
- difficulty prior: from `grade_level`, derived `age`, `confidence_by_subject`
- format prior: from `learning_style_preferences`
- scaffolding prior: from `support_needs`
- language prior: from `preferred_language`

If no personalization signals exist, recommendation logic falls back to baseline model behavior.

### FR-6: Generation prompt usage
AI generation context payload should include a compact profile personalization block:
- class/grade,
- preferred language,
- selected learning style preferences,
- support needs flags,
- subject confidence hint when available.

Prompt instructions must avoid stereotyping and must treat fields as *adaptation hints*, not constraints.

### FR-7: Privacy controls
- Gender is explicitly optional.
- Support-needs fields are optional and accompanied by non-medical framing.
- Parents can clear personalization data per field or fully reset to defaults.
- Deletion/reset actions must be auditable via backend logs.

---

## 5. User Experience Specification

### 5.1 Onboarding flow placement
1. Parent creates child profile (`name`, avatar, baseline class/grade).
2. App presents new step: “Personalize [Child Name]’s learning”.
3. Parent fills any subset of fields.
4. Parent continues to dashboard/recommendations.

### 5.2 Interaction design rules
- Form is sectioned into short cards:
  1) Class & language
  2) Learning preferences
  3) Support needs
  4) Confidence by subject
- Each section includes:
  - optional badge,
  - short value explanation,
  - skip affordance.
- Use plain language, avoid diagnosis wording (e.g., “Needs focus support” instead of medical labels).

### 5.3 Empty and partial states
- If all sections skipped: show “You can personalize later in Settings.”
- If partially filled: save available data; no validation errors for omitted sections.
- If confidence-by-subject absent: hide confidence-driven UI rather than showing zero values.

### 5.4 Transparency UI
Parent dashboard recommendation cards should include “Why this is suggested” with one to two personalization reasons when applicable (e.g., “Matched to preferred short sessions”).

---

## 6. Backend Data Model Specification

## 6.1 Storage design
Extend `child_profiles` entity with nullable fields:
- `school_class` (string, 50)
- `preferred_language` (string, 10)
- `gender` (string, 30)
- `gender_self_description` (string, 50)
- `learning_style_preferences` (json array)
- `support_needs` (json object)
- `confidence_by_subject` (json array)

Retain existing:
- `grade_level` (string)
- `birth_year` (integer)

### 6.2 Validation rules (API)
- enforce enum membership for constrained fields,
- reject oversized strings,
- coerce booleans in `support_needs`,
- validate confidence range 1..5,
- reject unknown keys in `support_needs` to prevent schema drift.

### 6.3 Derived age computation
- Add serialized/response-only `age` value in child profile API response.
- Age formula: `current_year - birth_year` with floor at 0 and ceiling sanity check at 25.
- If out-of-range birth year, API should fail validation on write.

---

## 7. API Contract Changes

### 7.1 Child profile create/update
- Extend `POST /api/child-profiles` and `PATCH /api/child-profiles/{id}` payloads to accept new fields.
- Maintain backward compatibility for existing clients sending only legacy fields.

### 7.2 Child profile read
`GET /api/child-profiles` and `GET /api/child-profiles/{id}` include:
- persisted personalization fields,
- derived `age` (nullable).

### 7.3 Error contract
Validation response should indicate:
- field-level errors,
- human-readable message,
- stable error code for client mapping where available.

---

## 8. Personalization Engine Integration

### 8.1 Recommendation scoring (phase 1 heuristic)
Composite score (illustrative):
- baseline relevance: 50%
- grade/age fit: 20%
- confidence gap targeting: 15%
- preferred format fit: 10%
- support-needs compatibility: 5%

Weights are configuration-driven and can be tuned without schema changes.

### 8.2 Generation adaptation rules
- If `dyslexia_friendly_mode = true`: prefer shorter sentences, increased spacing cues, reduced distractors.
- If `attention_support = true` or `short_bursts` style selected: prioritize 3–5 minute activities.
- If subject confidence ≤2: include gentler intro + at least one scaffold hint.

### 8.3 Fallback behavior
When personalization data is absent/partial:
- do not penalize user experience,
- use generic defaults,
- continue collecting outcomes to improve later recommendations.

---

## 9. Analytics & KPI Instrumentation

### 9.1 Event tracking
Track at minimum:
- `personalization_step_viewed`
- `personalization_step_skipped`
- `personalization_saved`
- `personalization_field_updated`
- `recommendation_served_with_personalization`

### 9.2 KPI definitions
Primary experiment KPIs aligned to backlog target:
- Session completion uplift in first 14 days after onboarding.
- D30 retention uplift for profiles with completed personalization.

### 9.3 Segmentation
Compare cohorts:
- no personalization,
- partial personalization,
- high-completion personalization (>= 3 sections completed).

---

## 10. Privacy, Consent, and Compliance

- Collect only fields required for adaptation; all sensitive-like fields optional.
- Explain purpose inline before data entry.
- Provide clear edit/delete/reset path in profile settings.
- Ensure data export/deletion pipeline includes new fields.
- Do not use gender as a direct difficulty or capability predictor.

---

## 11. Rollout Plan

### Phase A — Schema and API readiness
- Backend migration and validators.
- Mobile model compatibility update.
- Feature flag off by default.

### Phase B — Onboarding UI and profile settings
- Release personalization step to 10% of new profiles.
- Monitor completion, error rates, and drop-off.

### Phase C — Recommendation and generation consumption
- Enable ranking/prompt adaptations for flagged cohort.
- Validate learning outcomes and user sentiment.

### Phase D — General availability
- Ramp to 100% once KPI and quality gates pass.

---

## 12. Risks and Mitigations

- **Risk:** onboarding friction increases drop-off.
  - **Mitigation:** skippable sections + minimal required inputs.
- **Risk:** over-personalization biases recommendations.
  - **Mitigation:** bounded weights + fallback blend with baseline relevance.
- **Risk:** sensitive-data concerns from parents.
  - **Mitigation:** explicit optionality, purpose text, and easy deletion.

---

## 13. Acceptance Criteria

1. API accepts and returns all new profile fields with validation safeguards.
2. Onboarding step is fully skippable and does not block core app usage.
3. Recommendation service consumes available personalization signals without failure on missing data.
4. Generation prompt context includes personalization hints when present.
5. Parents can edit and clear personalization fields post-onboarding.
6. Instrumentation events are emitted for view/skip/save/update flows.
7. Privacy copy and controls are visible before and after data entry.

---

## 14. Dependencies

- `specs/business_specs.md` for value proposition alignment.
- `specs/technical_specs.md` for architecture constraints.
- Existing child profile domain and recommendation pipeline.

