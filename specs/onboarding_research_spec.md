# Onboarding Research Spec — Child-First + Parent-Supervised Flows

## 1. Objective
Design an onboarding experience that is:
- **Primary flow:** child-first, fun, and fast to start.
- **Secondary flow:** parent-first account creation with one or more child profiles and supervision controls.
- **Safety baseline:** compliant-by-design for underage users and transparent for families.

This document summarizes practical onboarding research patterns for education apps serving children and parents, then translates them into product recommendations for Learny.

---

## 2. Key Design Principles

1. **Fast first win (under 90 seconds):** get the child to a meaningful mini-learning action quickly.
2. **Progressive disclosure:** ask only the minimum information at first; collect richer profile data later.
3. **Dual-audience clarity:** every user must understand if they are in “Child mode” or “Parent mode.”
4. **Trust and consent by default:** legal consent, data usage explanation, and parent controls should be explicit and simple.
5. **Motivational onboarding:** use playful microinteractions, positive language, and immediate rewards.
6. **Recoverability:** users can pause onboarding and continue later without losing progress.

---

## 3. Personas and Jobs-to-be-Done

### Child (Primary)
- Wants to start quickly, avoid long forms, and feel competent immediately.
- Needs autonomy (especially on personal phone) with age-appropriate guardrails.
- Responds to avatars, streaks, short goals, and clear progress cues.

### Parent (Secondary)
- Wants confidence that the app is safe and educationally effective.
- Needs to create/manage multiple children, approve devices, and monitor progress.
- Cares about outcomes, transparency, and time efficiency.

---

## 4. Onboarding Architecture (Recommended)

### 4.1 Entry Split Screen
First screen: **“Who is using Learny today?”**
- “I’m a learner” (child-first)
- “I’m a parent/guardian”

Design notes:
- Friendly icons and plain language.
- Keep role switch always available from top-right (“Not you?”).

### 4.2 Child-First Main Flow (Primary)

#### Step C1 — Welcome + Promise (10–15s)
- One sentence value promise: “Learn from your real school topics in short game sessions.”
- Tap CTA: “Start learning.”

#### Step C2 — Lightweight Age & School Context (20–30s)
- Age bracket, school grade, preferred language.
- Optional: favorite subjects (chips with playful icons).
- Do **not** request long profile forms.

#### Step C3 — Identity Setup (20–30s)
- Child username + avatar selection (or auto-generated avatar first).
- If email/phone is required by policy, defer until after first learning moment when possible.

#### Step C4 — First Learning Moment (30–60s)
- Micro diagnostic game (3 questions max).
- End with celebration animation + “You unlocked your first learning streak.”

#### Step C5 — Optional Parent Link (Post-activation)
- Prompt: “Ask a parent to connect your account for progress reports and supervision.”
- Link options:
  - Parent invite code
  - QR pairing
  - Parent email invite

### 4.3 Parent-First Secondary Flow

#### Step P1 — Parent Account Creation
- Email/password or social sign-in.
- Consent + terms + privacy acknowledgment in clear, plain language.

#### Step P2 — Add Child Profiles
- Create one or more child profiles in one session.
- Required child fields: first name/nickname, age/grade, language.
- Optional fields: school system/curriculum, learning goals.

#### Step P3 — Child Device Linking
- Parent sees child-specific QR code / code.
- Child enters code on their phone to bind device.
- Parent can name devices and revoke access.

#### Step P4 — Parent Control Quick Setup
- Weekly study target.
- Notification preferences.
- Permissions (upload allowed, chat/help interactions, reminders).

#### Step P5 — Parent Dashboard First Insight
- Immediate “empty-state but useful” dashboard:
  - “No sessions yet; here is what you will track.”
  - Show upcoming metrics: consistency, weak topics, mastery growth.

---

## 5. Multi-Child Family Model

Recommended account structure:
- **Parent account** (owner)
  - 1..N **child profiles**
  - Each child has 1..N linked devices
  - Parent-level controls can inherit to children, with per-child overrides

Recommended onboarding behavior:
- Ask “How many children do you want to add now?” with “Add another” loop.
- Provide clear profile switching for parent dashboard.
- Child app should always boot directly into that child profile (no accidental sibling crossover without PIN).

---

## 6. Safety, Consent, and Compliance-by-Design (Research Guidance)

> Note: final legal implementation must be validated with counsel for target markets.

Minimum product requirements to include in onboarding:
1. **Age-gating:** detect underage paths and apply child-safe defaults.
2. **Parental consent flow:** for jurisdictions requiring verified parent consent before full feature access.
3. **Data minimization:** collect only what is required for educational function.
4. **Explainability:** simple “what data we collect and why” summary.
5. **Parental rights controls:** review/delete child data, manage access, export progress.
6. **High-privacy defaults:** private profiles, limited discoverability, no ad-tech tracking.

UX recommendation:
- Use a short “Safety & Privacy in 3 bullets” card during onboarding, with “Learn more” for full policy.

---

## 7. Child Engagement Patterns That Improve Onboarding Completion

1. **Avatar-first identity:** selecting an avatar increases emotional ownership.
2. **Immediate competence loop:** very easy first activity to guarantee early success.
3. **Visible short progress bar:** “Step 2 of 4” reduces uncertainty.
4. **Small rewards:** first badge, starter streak, celebratory animation.
5. **Warm, non-evaluative copy:** avoid school-test anxiety language.
6. **Single-action screens:** one decision per step for cognitive simplicity.

Suggested tone examples:
- “Let’s build your learning hero profile!”
- “Nice! You’re ready for your first challenge.”
- “Great effort — you unlocked your daily spark ✨”

---

## 8. Parent Trust Patterns That Improve Conversion

1. **Outcome preview before commitment:** show what parent will be able to monitor.
2. **Time-cost transparency:** “Setup takes ~2 minutes.”
3. **Control transparency:** clearly list supervision capabilities.
4. **Educational methodology summary:** explain why mini-games improve retention.
5. **No dark patterns:** explicit permission choices and easy opt-out.

---

## 9. Recommended End-to-End Funnel

### Child-first funnel
1. Role selection
2. Child profile quick setup
3. First learning moment
4. Optional parent linking
5. Return loop to daily session

### Parent-first funnel
1. Parent signup
2. Create children
3. Link child devices
4. Configure supervision
5. Child completes first learning moment

Primary product KPI for onboarding quality:
- **Time to First Learning Value (TTFLV):** median time from app open to first completed learning interaction.

Secondary KPIs:
- Child onboarding completion rate
- Parent linking rate (from child-first path)
- Multi-child setup completion rate
- Day-1 return rate
- Day-7 retained learners (with and without linked parent)

---

## 10. Proposed Learny Onboarding V1 (Actionable)

### V1 scope
- Role selection screen
- Child-first onboarding (4 lightweight steps + first micro-game)
- Parent account + multi-child creation
- Parent-child linking via code/QR
- Minimal supervision settings

### V1 non-goals
- Deep parental analytics during onboarding
- Complex curriculum mapping during onboarding
- Long personality/learning style questionnaires

### V1 UX constraints
- Max 5 screens before first child activity
- Max 3 required inputs per screen
- Every step skippable where legally allowed
- Recovery path from interruption (save draft onboarding state)

---

## 11. Experimentation Roadmap

A/B tests to run after V1:
1. **Role screen copy** (“Learner” vs “Child”).
2. **Avatar timing** (before vs after first game).
3. **Parent link prompt timing** (immediate vs after 2 sessions).
4. **Progress indicator style** (linear bar vs step bubbles).
5. **Reward strategy** (badge only vs badge + confetti + message).

Success decision rules:
- Favor variants that improve TTFLV and D1 return without reducing parent trust metrics.

---

## 12. Implementation Notes for Product + Engineering

1. Model users with explicit roles and relationship bindings (`parent`, `child`, `guardian`).
2. Introduce onboarding state machine (per role) with resumable checkpoints.
3. Separate auth from profile completion to avoid friction.
4. Implement secure parent-child linking tokens (short-lived, single-use).
5. Add child device registration with revocation support.
6. Track onboarding analytics events with privacy-safe identifiers.

Suggested event taxonomy:
- `onboarding_role_selected`
- `child_profile_created`
- `first_learning_started`
- `first_learning_completed`
- `parent_signup_completed`
- `child_link_code_generated`
- `child_device_linked`
- `parent_controls_configured`

---

## 13. Risks and Mitigations

- **Risk:** child drop-off from form friction.
  - **Mitigation:** reduce required fields and defer non-critical inputs.

- **Risk:** parent mistrust around data handling.
  - **Mitigation:** upfront safety summary and transparent controls.

- **Risk:** confusion between child/parent modes.
  - **Mitigation:** explicit mode labels, visual cues, and easy role switch.

- **Risk:** sibling account mix-ups on shared devices.
  - **Mitigation:** profile PIN and clear active-child indicator.

---

## 14. Open Questions

1. Which launch markets define consent/age requirements for V1?
2. Is child self-signup allowed before verified parent connection in target regions?
3. What level of parent control is mandatory at launch vs post-MVP?
4. Should parent supervision include real-time notifications or only daily summaries initially?

---

## 15. Recommendation Summary

- Keep **child-first onboarding** as the default growth path.
- Introduce a robust **parent-first path** for families with multiple children.
- Prioritize **fast first learning value**, **clear trust communication**, and **safe account linking**.
- Measure success via TTFLV, completion, linking, and retention.

This approach balances engagement for children with confidence and control for parents, while preserving product simplicity in MVP.

---

## 16. Screen-Level Requirements (MVP)

### Child-first screens

| Screen | Goal | Required inputs | Exit criteria |
|---|---|---|---|
| Role selection | Route user to correct onboarding | 1 tap (`child`/`parent`) | `onboarding_role_selected` fired |
| Child quick profile | Capture minimum setup | age bracket, grade, language | child profile draft saved |
| Avatar + nickname | Build identity and motivation | nickname, avatar | `child_profile_created` fired |
| First challenge | Deliver first value quickly | none (activity only) | `first_learning_completed` fired |
| Parent link prompt (optional) | Offer supervision link | skip or link method | prompt dismissed or link created |

### Parent-first screens

| Screen | Goal | Required inputs | Exit criteria |
|---|---|---|---|
| Parent signup | Create supervising account | email + password (or SSO) | parent account created |
| Add children | Create one or more child profiles | name/nickname, age/grade, language per child | at least 1 child created |
| Link devices | Bind child phone(s) securely | link method (QR/code) | device link confirmed |
| Controls setup | Configure supervision baseline | weekly target + notifications | settings persisted |
| Dashboard preview | Build trust with clear outcome | none | parent reaches home dashboard |

---

## 17. Consent and Age Decision Matrix (Product Rules)

| Child age band | Account start allowed | Parent verification required | Feature limitations before verification |
|---|---|---|---|
| Under local digital-consent age | Yes, child can begin limited experience | Yes, before full account activation | no social/discovery features, limited retention, restricted messaging |
| At/above local digital-consent age but under 18 | Yes | Recommended for supervision features | default private profile and safety prompts |
| 18+ (if applicable) | Yes | No | standard learner experience |

Implementation notes:
- “Local digital-consent age” must be configurable per market/country.
- If jurisdiction prohibits pre-consent data persistence, switch from persistent profile to temporary session until consent completes.

---

## 18. Acceptance Criteria (Definition of Done for Onboarding V1)

### Child-first
1. A new child user can reach the first completed learning activity in <= 90 seconds median in production telemetry.
2. No child-first screen requires more than 3 mandatory inputs.
3. Onboarding resumes at the exact previous step after app restart.
4. Parent-link prompt appears only after first activity completion and can be skipped.

### Parent-first
1. Parent can create at least two child profiles in a single onboarding session.
2. Parent can generate link code/QR and bind at least one child device.
3. Parent can revoke a linked device from settings.
4. Parent sees onboarding-complete dashboard state even when no child activity exists yet.

### Safety and analytics
1. Age-gate policy is enforced before feature unlocks requiring consent.
2. Required onboarding analytics events are emitted exactly once per completed step.
3. Data collection during onboarding is limited to the fields listed in this document plus legal/auth necessities.

---

## 19. Delivery Plan (Suggested)

### Phase 1 — Foundations
- Role split entry, onboarding state machine, analytics instrumentation, and age-gating policy hooks.

### Phase 2 — Child-first launch
- Child quick profile, avatar/nickname, first challenge, post-activation parent-link prompt.

### Phase 3 — Parent-first supervision
- Parent signup, multi-child creation, code/QR linking, device revocation, minimal controls.

### Phase 4 — Optimization
- A/B testing, copy iteration, and market-specific consent tuning.

Exit criteria per phase should include funnel metrics and privacy/compliance checks before rollout expansion.

