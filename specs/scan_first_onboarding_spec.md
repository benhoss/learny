# Product Requirements Document (PRD) — Scan-First Onboarding (Learning-First)

## 1. Document Status
- **Owner:** Product
- **Contributors:** Engineering, Design, Data, Compliance
- **Status:** Draft for implementation planning
- **Related specs:**
  - `specs/business_specs.md`
  - `specs/technical_specs.md`
  - `specs/onboarding_research_spec.md`
  - `specs/onboarding_implementation_prd.md`

---

## 2. Problem Statement
Current onboarding still creates identity/setup friction before a child gets value. For this audience, the fastest way to engage is immediate action on real homework.

We need a flow where the first experience is:
1. Scan homework.
2. Receive auto-generated quiz.
3. Complete quiz and see feedback.
4. Only then ask to save/link account (optional initially).

---

## 3. Product Goals
1. **Value-first activation:** remove mandatory account gating before first completed quiz.
2. **Faster TTFLV:** median time from app open to first completed quiz under 90 seconds.
3. **Higher conversion quality:** increase account-link conversion after user has experienced value.
4. **Full compatibility:** implement as an additive variant to the existing onboarding PRD, not a replacement.

### Non-goals (V1)
- Redesign legal frameworks per market.
- Anonymous cross-device sync before linking.
- Pricing/paywall redesign.

---

## 4. Personas and Jobs-to-be-Done

### Primary Persona — Child Learner (10–14)
- Wants to start quickly and avoid forms.
- Wants instant feedback on school material.

### Secondary Persona — Parent/Guardian
- Wants supervision, safety, and continuity.
- Wants child progress preserved after linking.

### Core Jobs
- Child: "Help me practice this homework now."
- Parent: "Let my child start easily, then connect safely to my account."

---

## 5. User Stories

### Epic A — Immediate Learning Start
1. **As a child**, I want to scan homework immediately so I can start learning without signing up first.
   **Acceptance Criteria:**
   - App exposes a primary CTA to scan homework from first launch.
   - No account creation is required before first quiz completion.

2. **As a child**, I want to get a quiz from my scan so I can practice instantly.
   **Acceptance Criteria:**
   - Guest flow supports upload/scan, generation, and quiz completion.
   - Results are shown with clear feedback after quiz completion.

### Epic B — Progressive Account Commitment
3. **As a child**, I want to choose whether to link an account after my first quiz so I don’t lose momentum.
   **Acceptance Criteria:**
   - Post-quiz prompt includes: Save my progress, Link with parent, Maybe later.
   - Maybe later is non-blocking for at least one additional completed session.

4. **As a parent**, I want to link my child after first usage so progress is supervised and preserved.
   **Acceptance Criteria:**
   - Parent linking reuses existing approved linking methods.
   - Linked child profile receives migrated guest artifacts.

### Epic C — Data Continuity and Safety
5. **As a user**, I want my guest progress to move safely into my account so I keep my work.
   **Acceptance Criteria:**
   - Migration endpoint is atomic and idempotent.
   - Merge audit logs are recorded.

6. **As a compliance stakeholder**, I want existing consent and age controls preserved so the new flow remains safe-by-default.
   **Acceptance Criteria:**
   - Existing age-gate and consent logic remains enforced.
   - Restricted features remain blocked until identity/consent requirements are met.

---

## 6. Scope (MVP)

### In Scope
- Guest session creation on first launch.
- Scan/upload before authentication.
- Generate and complete first quiz in guest mode.
- Post-quiz linking prompt with skippable option.
- Guest-to-account artifact migration.
- Analytics instrumentation for scan-first funnel.

### Out of Scope
- New parental controls UX redesign.
- Pre-link cross-device persistence.
- New monetization experiments.

---

## 7. End-to-End User Flow

### 7.1 Guest First Session
1. Open app.
2. Tap **Scan homework now**.
3. Capture/upload homework.
4. Quiz generation completes.
5. Child completes quiz.
6. Results screen appears.
7. Prompt appears: Save my progress / Link with parent / Maybe later.

### 7.2 Guest Follow-up
- If Maybe later is selected, child can complete at least one additional session without forced signup.
- Before data-risk moments (reinstall/logout/device switch), app shows save/link reminder.

### 7.3 Parent Linking After Value
1. Child selects Link with parent.
2. Parent verification/linking via existing approved mechanism.
3. Guest artifacts merge into child profile.
4. Parent supervision and cross-device continuity become available.

---

## 8. Functional Requirements

### 8.1 Session Model
- System creates `guest_session_id` when no account exists.
- Guest can access scan/upload, generation, quiz, and results.
- Guest cannot access parent dashboard or cross-device history.

### 8.2 Post-Quiz Linking
- Link prompt triggers after first completed quiz.
- Required prompt intents:
  - Save my progress
  - Link with parent
  - Maybe later
- Maybe later must remain non-blocking for one additional completed learning session minimum.

### 8.3 Migration and Ownership
- Guest artifacts are ownership-tagged.
- `POST /guest/link-account` migrates guest artifacts atomically.
- Retry behavior is idempotent.
- Merge actions must produce auditable records.

### 8.4 Guardrails
- Durable identity features (cross-device sync, parent controls, long-term backup) require linked account.
- Data-risk transitions must trigger save/link warning UI.
- Existing consent and age-gate rules from onboarding PRD remain mandatory.

---

## 9. Data, API, and State Requirements

### 9.1 Data Model Deltas
- `owner_type`: `guest | child`
- `owner_guest_session_id` (nullable)
- `owner_child_id` (nullable)

### 9.2 API Deltas
- Guest-capable scan/upload/generation endpoints using `guest_session_id` and device signature.
- `POST /guest/link-account` for migration.

### 9.3 State Machine Integration
- Reuse existing onboarding state machine.
- Add `guest_prelink` state rather than introducing a separate engine.

---

## 10. Analytics and Success Metrics

### 10.1 Required Events
- `guest_session_started`
- `scan_started`
- `scan_uploaded`
- `quiz_generated`
- `quiz_completed`
- `link_prompt_shown`
- `link_prompt_accepted`
- `link_prompt_skipped`
- `guest_session_linked`

These complement existing onboarding events in `specs/onboarding_implementation_prd.md`.

### 10.2 KPI Targets
- **Primary:** TTFLV p50 < 90 seconds (scan-first cohort).
- **Secondary:**
  - `scan_started -> quiz_completed` completion uplift.
  - Link conversion within first 3 completed quizzes.
  - D1/D7 retention uplift vs identity-first baseline.
- **Guardrails:**
  - Guest scan failure rate.
  - Migration failure rate.
  - Parent-link completion failure rate.

---

## 11. Dependencies and Reuse Constraints
To avoid reinventing existing architecture, implementation must reuse:
1. Role and supervision model (`child`, `parent`) from onboarding PRD.
2. Existing consent/age-gate policy enforcement.
3. Existing parent-child link method (code/QR or approved equivalent).
4. Existing onboarding analytics conventions.
5. Existing resumable onboarding state machine, extended with `guest_prelink`.

---

## 12. Rollout Plan
1. **Phase 1 — Internal QA:** validate guest scan, quiz completion, and migration.
2. **Phase 2 — Controlled rollout:** 20% traffic A/B vs current onboarding.
3. **Phase 3 — Scale:** 100% rollout if KPI improvements are confirmed and guardrails remain healthy.

---

## 13. Definition of Done
1. First quiz can be completed without account creation.
2. Post-quiz link prompt is shown and skippable.
3. Guest migration is atomic, idempotent, and logged.
4. Required events are visible in analytics dashboards.
5. Product, engineering, data, and compliance sign off on rollout readiness.

---

## 14. Risks and Mitigations
- **Risk:** guest abuse/spam uploads.
  **Mitigation:** per-device throttling, abuse heuristics, and rate limits.
- **Risk:** perceived data loss in guest mode.
  **Mitigation:** clear copy + risk-point reminders to save/link.
- **Risk:** parent trust concerns on child-first entry.
  **Mitigation:** explicit post-value parent-link and safety messaging.
- **Risk:** migration conflicts/retries.
  **Mitigation:** idempotent merge semantics + merge audit trail.

---

## 15. Open Questions
1. What is the maximum allowed guest sessions before stronger linking nudges?
2. Which parent verification method is default for launch markets?
3. Should guest artifacts expire after a fixed inactivity window?
4. What copy variants maximize post-quiz link conversion without harming D1 retention?
