# Product Requirements Document (PRD) — Onboarding Implementation (Child-First + Parent-Supervised)

## 1. Document Status
- **Owner:** Product
- **Contributors:** Engineering, Design, Data, Compliance
- **Status:** Draft for implementation planning
- **Related specs:**
  - `specs/onboarding_research_spec.md`
  - `specs/business_specs.md`
  - `specs/technical_specs.md`
  - `specs/scan_first_onboarding_spec.md`

---

## 2. Problem and Opportunity
Learny needs an onboarding experience that helps children reach learning value quickly while also enabling parent supervision and trust. Current direction exists at research/spec level, but implementation requires a concrete PRD with functional scope, acceptance criteria, event instrumentation, and rollout phases.

---

## 3. Product Goals
1. **Child-first activation:** a child reaches first completed learning interaction in <= 90 seconds median (TTFLV).
2. **Parent supervision path:** parents can create and supervise one or more child profiles.
3. **Safe by default:** onboarding enforces age/consent guardrails and privacy-first defaults.
4. **Implementation-ready clarity:** product/design/engineering align on a single MVP contract.

### Non-goals (V1)
- Deep parent analytics setup during onboarding.
- Full curriculum mapping during onboarding.
- Long psychometric/learning-style questionnaires.

---

## 4. Users and Core Jobs

### Primary user: Child learner (10–14)
- Wants a fast, playful start.
- Needs low-friction setup and immediate success.

### Secondary user: Parent/guardian
- Wants safety, transparency, and visible educational outcomes.
- Needs multi-child management and device supervision.

---

## 5. Success Metrics

### Primary KPI
- **TTFLV:** median time from app open to first completed learning interaction.

### Secondary KPIs
- Child onboarding completion rate.
- Parent onboarding completion rate.
- Parent-link rate from child-first flow.
- Multi-child setup completion rate.
- D1 and D7 retention for child accounts.

### Guardrail Metrics
- Consent drop-off rate.
- Age-gate error rate.
- Device-link failure rate.

---

## 6. Scope (MVP)

### In scope
- Role split entry (`child` / `parent`).
- Child-first onboarding flow (profile minimum + avatar + first challenge).
- Additive scan-first guest path (scan -> quiz -> post-quiz linking prompt), as defined in `specs/scan_first_onboarding_spec.md`.
- Parent-first onboarding flow (signup + multi-child + linking + basic controls).
- Parent-child linking via short-lived code/QR.
- Resumable onboarding state.
- Required onboarding analytics events.

### Out of scope
- Advanced parental reporting configuration during onboarding.
- Cross-household custody/complex guardianship workflow.
- Real-time parent alerts customization beyond baseline controls.

---

## 7. End-to-End User Flows

## 7.1 Child-first flow (primary)
1. User selects **“I’m a learner.”**
2. Child enters minimal profile inputs (age bracket, grade, language).
3. Child picks nickname + avatar.
4. Child completes first micro-learning challenge.
5. Optional parent-link prompt is shown (skip allowed).
6. Child is routed to normal app home.

Scan-first additive variant:
- Instead of profile-first as step 2, the child may start with homework scan -> generated quiz -> results.
- Profile/linking prompts appear post-value, while maintaining existing age/consent and supervision constraints.

## 7.2 Parent-first flow (secondary)
1. User selects **“I’m a parent/guardian.”**
2. Parent creates account (email/password or SSO where available).
3. Parent adds one or more child profiles.
4. Parent links child device via code/QR.
5. Parent configures baseline supervision controls.
6. Parent lands on dashboard preview state.

---

## 8. Functional Requirements

## 8.1 Role Entry
- App must present clear role split at entry.
- Role selection must be reversible from onboarding screens.

## 8.2 Child Onboarding
- Max 5 screens before first activity.
- No more than 3 required fields on any child setup screen.
- First challenge must be <= 3 questions and suitable for immediate success.
- Parent-link step must be optional and post-activation.

## 8.3 Parent Onboarding
- Parent can create at least two child profiles in one session.
- Parent can generate a child-specific link token (code/QR).
- Parent can name and revoke linked child devices.

## 8.4 Safety and Consent
- Age-gate policy must be evaluated before unlocking restricted features.
- Local digital-consent age must be configurable by market.
- If required by jurisdiction, verified parent consent gate must block full activation.

## 8.5 Onboarding State and Recovery
- Progress checkpoints must persist and restore after app restart.
- Interrupted flows must resume at the last incomplete step.

## 8.6 Analytics Events (minimum)
- `onboarding_role_selected`
- `child_profile_created`
- `first_learning_started`
- `first_learning_completed`
- `parent_signup_completed`
- `child_link_code_generated`
- `child_device_linked`
- `parent_controls_configured`

---

## 9. UX and Content Requirements
- Child-facing copy must be short, warm, and non-evaluative.
- Parent-facing copy must emphasize safety, transparency, and control.
- Progress indication should remain visible during onboarding.
- Legal/safety copy should include a concise summary plus link to full policy.

---

## 10. Data and Privacy Requirements
- Data minimization during onboarding: collect only fields required for activation and compliance.
- Child profiles default to private visibility.
- No ad-tech tracking patterns in child onboarding.
- Parent rights actions (review/delete/export) must be discoverable from account settings post-onboarding.

---

## 11. Technical Requirements
- Implement onboarding as a resumable state machine keyed by role.
- Use short-lived, single-use parent-child linking tokens.
- Record analytics with privacy-safe identifiers.
- Support device registration metadata and revocation capability.

---

## 12. Acceptance Criteria (MVP DoD)

### Child-first
1. TTFLV median <= 90 seconds in production telemetry.
2. Child can complete onboarding and first challenge without email requirement where legally permitted.
3. Parent-link prompt appears after first completed challenge and is skippable.

### Parent-first
1. Parent can complete onboarding with >= 2 child profiles in one session.
2. Parent can successfully link at least one child device via code/QR.
3. Parent can revoke a linked device.

### Safety and reliability
1. Age-gate and consent constraints are enforced according to configured market policy.
2. Onboarding resumes after interruption without step loss.
3. Required events fire once per completed step.

---

## 12A. Scan-First Variant Integration (Additive)
The scan-first onboarding variant is implemented as an additive path within this PRD scope.

### Variant contract
1. First mandatory user action in child-first path can be homework scan instead of profile setup.
2. Account creation/linking prompt appears after first completed quiz and remains skippable initially.
3. Existing age/consent, parent-supervision, and analytics guardrails remain mandatory.
4. Guest artifacts must be mergeable into child accounts via idempotent linking.

### Variant acceptance checks
- Child can complete first quiz from scan flow without auth blocker.
- `guest_session_linked` can be correlated to later `child_profile_created` / linked parent events.
- Parent linking remains available after first value moment.

---

## 13. Rollout Plan

### Phase 1: Foundation
- Role entry, state machine, age-gate hooks, event scaffolding.

### Phase 2: Child-first launch
- Child setup + first challenge + optional parent-link prompt.

### Phase 3: Parent-first launch
- Parent signup + multi-child + device linking + controls.

### Phase 4: Optimization
- A/B tests on copy, avatar timing, prompt timing, progress UI.

---

## 14. Risks and Mitigations
- **Risk:** child drop-off due to friction.
  - **Mitigation:** strict input limits and progressive disclosure.
- **Risk:** parent trust concerns.
  - **Mitigation:** explicit privacy summary and clear controls.
- **Risk:** linking confusion.
  - **Mitigation:** dual link options (QR/code) + fallback instructions.
- **Risk:** market compliance variation.
  - **Mitigation:** configurable consent policy by jurisdiction.

---

## 15. Open Decisions
1. Launch-market order for consent/legal policy matrix.
2. Minimum verified-consent method for market set #1.
3. Exact baseline parent controls for V1 (final list).
4. Whether child self-start mode stores persistent data pre-consent in each market.
