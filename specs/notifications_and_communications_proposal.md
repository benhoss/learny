# Smart Notifications & Communications Proposal

## 1. Purpose
Design a complete cross-channel notification system (push + email, with optional in-app inbox) that improves learning consistency, supports parent supervision, and stays safe for children.

This proposal defines:
- Product strategy (who gets what, when, and why).
- UX behavior in the mobile app.
- Backend architecture and delivery pipeline.
- Data model and API contracts.
- Safety/compliance guardrails.
- Rollout and success metrics.

---

## 2. Goals and Non-Goals

### 2.1 Goals
- Increase healthy learning frequency (especially 3–10 minute sessions).
- Reduce churn by nudging at the right moment, not by spamming.
- Help parents stay informed with digest-style communication.
- Deliver notifications reliably from backend systems.
- Respect consent, quiet hours, locale, and user preferences.

### 2.2 Non-Goals (MVP)
- Building a full marketing automation platform.
- Sending high-frequency promotional campaigns.
- Real-time chat/messaging between users.

---

## 3. Audience and Channel Strategy

### 3.1 Child-facing
Primary channel: native push notifications.
Secondary channel: in-app notification center (already aligned with existing notifications screen concept).

Child notification themes:
- Learning streak reminders.
- “Revision Express” before known assessment windows.
- Positive reinforcement (achievement unlocked, mastery milestone).
- New learning pack ready after upload/processing.

### 3.2 Parent-facing
Primary channel: email digests and critical alerts.
Secondary channel: push notifications for opted-in urgent events.

Parent notification themes:
- Weekly progress digest.
- “Needs attention” alerts (drop in activity, repeated low mastery).
- Operational alerts (document processed, action needed).

### 3.3 Channel decision matrix
- Immediate and time-sensitive learning nudge → push.
- Rich summary with charts/context → email.
- Missed push/open-failure fallback for high-priority items → delayed email fallback.

---

## 4. UX Principles for “Smart” Notifications

1. **Intent first, then channel:** decide educational objective before selecting push/email.
2. **Right time > more messages:** use learner routines and local timezone.
3. **Age-safe language:** no anxiety-inducing copy; always supportive and actionable.
4. **Control and transparency:** easy preference toggles per child/parent persona.
5. **Never interrupt active session:** suppress non-critical notifications while in-game.
6. **Closed-loop UX:** tapping notification deep-links directly to relevant app screen.

---

## 5. Notification Taxonomy

Each notification has:
- `type` (what happened)
- `intent` (why send)
- `audience` (`child`, `parent`)
- `priority` (`critical`, `high`, `normal`, `low`)
- `channel` (`push`, `email`, `in_app`)

Recommended initial types:

1. `learning_reminder_due`
2. `streak_at_risk`
3. `revision_window_open`
4. `learning_pack_ready`
5. `achievement_unlocked`
6. `weekly_progress_digest`
7. `mastery_alert_parent`
8. `consent_or_security_alert`

---

## 6. Triggering and Orchestration Model

### 6.1 Event-driven pipeline
Use backend domain events as the source of truth:
- `SessionCompleted`
- `PackGenerated`
- `AssessmentImported`
- `StreakUpdated`
- `MasteryUpdated`
- `ChildInactiveDetected`

Each event enters a notification rules engine:
1. Evaluate eligibility and consent.
2. Apply frequency caps and quiet hours.
3. Personalize template payload.
4. Schedule/send via channel adapters.
5. Record delivery and engagement outcomes.

### 6.2 Rules engine policy layers
- **Eligibility:** role, age bracket, active child profile, locale.
- **Preference checks:** push/email toggles, reminder opt-in.
- **Fatigue controls:** daily/weekly caps, dedupe window (for example 12h).
- **Priority override:** critical safety/security bypasses non-critical caps.

### 6.3 Scheduling intelligence (MVP → v2)
- MVP: heuristic send windows based on historical active hours.
- v2: model-based send-time optimization by cohort.

---

## 7. Backend Architecture Proposal

## 7.1 Components
1. **Notification Service (Laravel module)**
   - Consumes domain events.
   - Computes recipients and templates.
   - Creates canonical notification jobs.

2. **Queue + Workers (Redis queues)**
   - Dedicated queues per channel (`notifications_push`, `notifications_email`).
   - Retry strategy with exponential backoff.

3. **Channel Providers**
   - Push adapter: FCM/APNs abstraction.
   - Email adapter: transactional provider (e.g., SES, SendGrid, Postmark).

4. **Notification Ledger (MongoDB collections)**
   - Immutable log of intents, sends, failures, opens, clicks.

5. **Preference Service**
   - Stores per-user and per-child communication preferences.

### 7.2 Reliability requirements
- At-least-once job execution + idempotency keys per notification.
- Provider timeout handling and retry with jitter.
- Dead-letter queue for repeated failures.
- Observability dashboards (send success rate, median delay, fail reasons).

### 7.3 Suggested collections

#### `notification_preferences`
- `user_id`
- `child_id` (nullable for parent-global preferences)
- `channel_settings` (push/email/in_app)
- `quiet_hours` (start/end/local timezone)
- `frequency_caps` (daily/weekly)
- `updated_at`

#### `notification_campaigns`
Defines reusable templates and policy metadata:
- `campaign_key`
- `type`
- `audience`
- `default_priority`
- `template_ref_push`
- `template_ref_email`
- `enabled`

#### `notification_events`
Canonical send record:
- `event_id` (idempotency key)
- `user_id` / `child_id`
- `campaign_key`
- `channel`
- `status` (`queued`, `sent`, `delivered`, `opened`, `clicked`, `failed`, `suppressed`)
- `provider_message_id`
- `scheduled_for`
- `sent_at`
- `failure_reason`
- `context_payload`

#### `device_tokens`
- `user_id`
- `child_id` (if device linked to child profile)
- `platform` (`ios`, `android`)
- `token`
- `locale`
- `timezone`
- `last_seen_at`
- `revoked_at`

---

## 8. API Contracts (Proposed)

### 8.1 App → Backend
1. `POST /v1/notifications/device-tokens`
   - Register/update push token.

2. `DELETE /v1/notifications/device-tokens/{tokenId}`
   - Revoke token on logout/device unlink.

3. `GET /v1/notifications/preferences`
4. `PUT /v1/notifications/preferences`
   - Update toggles, quiet hours, digest cadence.

5. `GET /v1/notifications/inbox?cursor=...`
   - Fetch in-app notifications feed.

6. `POST /v1/notifications/{id}/read`
   - Mark read for inbox state consistency.

### 8.2 Internal/backend endpoints (optional)
- `POST /internal/notifications/trigger`
- `POST /internal/notifications/retry/{eventId}`

---

## 9. Personalization Logic

### 9.1 Inputs
- Last 7/30-day activity profile.
- Streak status.
- Weak areas and pending revision topics.
- School assessment dates (if present).
- Prior notification interactions (open/click/ignore).

### 9.2 Decision examples
- If child hasn’t studied in 48h and local time is in preferred window, send `learning_reminder_due`.
- If exam is within 72h and weak topic unresolved, send `revision_window_open`.
- If 3 reminders ignored this week, downgrade cadence and switch to parent digest mention (instead of more child nudges).

### 9.3 Guardrails
- Hard cap example: max 2 child push reminders/day, max 6/week.
- No push between 20:30 and 07:00 local time (configurable per market).
- Avoid negative framing (“you are behind”); use positive prompts.

---

## 10. Content and Template Strategy

### 10.1 Push content schema
- `title`
- `body`
- `deeplink`
- `campaign_key`
- `personalization_tokens`

### 10.2 Email content schema
- Subject line + preheader.
- Structured sections: wins, weak spots, recommended next action.
- Clear CTA deep-linking to parent dashboard or child activity.

### 10.3 Localization
- Template variants by language (`en`, `fr`, `nl`, others).
- Fallback locale chain with default English.

---

## 11. Security, Privacy, and Compliance

1. COPPA/GDPR-K aligned controls for child data handling.
2. Parent consent gate for child notifications where required.
3. Data minimization in payloads (never include sensitive raw school data in push text).
4. Signed deep links and authenticated destination checks.
5. Preference changes and suppression decisions are audit-logged.

---

## 12. Analytics and Experimentation

### 12.1 Core funnel metrics
- Send rate, delivery rate, open rate, click/open-to-session conversion.
- Reminder-to-learning-session conversion within 24h.
- Incremental retention lift (D7/D30) for opted-in cohorts.
- Unsubscribe/disable rate by campaign type.

### 12.2 Experimentation plan
- A/B test reminder timing windows.
- A/B test supportive copy variants.
- Holdout group for causal impact on learning sessions.

### 12.3 Alerting thresholds
- Delivery success < 95% for any channel over 30 minutes.
- Spike in `failed` or `suppressed` statuses.
- Significant jump in opt-out rate after campaign rollout.

---

## 13. Rollout Plan

### Phase 1 (Foundation)
- Device token registration.
- Preferences APIs + UI wiring.
- Push provider integration + simple reminder campaigns.
- Notification ledger and dashboards.

### Phase 2 (Smart Rules)
- Event-driven rules for streak risk, pack ready, and inactivity.
- Parent weekly email digest.
- Frequency caps + quiet hours fully enforced.

### Phase 3 (Optimization)
- Send-time optimization.
- Campaign experimentation tooling.
- Cross-channel fallback optimization.

---

## 14. Definition of Done (Notifications Initiative)

- End-to-end flow works for at least 3 notification types (`learning_reminder_due`, `learning_pack_ready`, `weekly_progress_digest`).
- Preferences are honored consistently across push and email.
- Delivery, open, and failure analytics available in dashboards.
- Quiet hours and frequency caps pass automated policy tests.
- Legal/privacy review completed for child-facing communications.

---

## 15. Risks and Mitigations

1. **Notification fatigue**
   - Mitigate with strict caps, suppression rules, and engagement-aware throttling.

2. **Provider lock-in**
   - Mitigate via adapter abstraction and provider-agnostic event model.

3. **Low push deliverability**
   - Mitigate token hygiene jobs, fallback channels, and provider monitoring.

4. **Regulatory complexity across regions**
   - Mitigate policy layer with market-specific defaults and legal review checklist.

---

## 16. Recommended Next Implementation Tasks

1. Add backend notification domain module and queue workers.
2. Add device token + preferences API endpoints.
3. Add app-side permission flow and preferences screens wiring.
4. Ship 3 initial campaigns with templates and localization.
5. Add instrumentation and dashboards before broad rollout.
