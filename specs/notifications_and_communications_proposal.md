# Smart Notifications & Communications Proposal

## 1. Purpose
Define a complete, implementation-ready notification system for Learny that combines native push notifications, email, and in-app inbox updates.

The system must:
- Increase child learning consistency (short, frequent study sessions).
- Keep parents informed and in control.
- Respect child-safety and legal constraints.
- Be reliable and observable from the backend.

---

## 2. Research and Product Analysis Summary

### 2.1 Inputs considered
This proposal is aligned with:
- Learny business goals: engagement, retention, mastery progression.
- Learny technical constraints: Laravel backend, Redis queues, MongoDB, mobile app with user settings state.
- Existing app UX direction: notification center, reminders toggle, parent supervision model.

### 2.2 Notification design findings applied
1. **Behavior change works best with short action loops**: reminder should drive a concrete next action (e.g., “Start 5-minute Revision Express”), not generic motivation.
2. **Parent and child messaging should be intentionally different**: child = short and encouraging; parent = contextual digest and supervision.
3. **Over-sending harms trust and retention**: strict frequency caps and quiet hours are mandatory.
4. **Reliability beats complexity at launch**: event-driven workflows + robust retries before advanced ML timing.

### 2.3 Product hypothesis
If reminders are personalized, capped, and tied to real learning opportunities, Learny should improve session starts and retention without increasing opt-outs.

---

## 3. Goals and Non-Goals

### 3.1 Goals
- Increase healthy learning frequency (3–10 minute sessions).
- Improve D7/D30 retention through timely nudges.
- Provide parent visibility through useful summaries.
- Deliver notifications with high reliability and low latency.
- Ensure legal/privacy-safe communication with minors.

### 3.2 Non-Goals (MVP)
- Marketing/promotional campaigns engine.
- Real-time chat-style communications.
- Complex AI copy generation for every notification.

---

## 4. Audience and Channel Strategy

### 4.1 Child-facing
- Primary: native push.
- Secondary: in-app inbox card.

Use cases:
- `learning_reminder_due`
- `streak_at_risk`
- `revision_window_open`
- `learning_pack_ready`
- `achievement_unlocked`

### 4.2 Parent-facing
- Primary: email digest + operational alerts.
- Secondary: push for urgent opted-in events.

Use cases:
- `weekly_progress_digest`
- `mastery_alert_parent`
- `consent_or_security_alert`

### 4.3 Channel decision matrix
| Situation | Preferred channel | Fallback |
|---|---|---|
| Time-sensitive learning prompt | Push | In-app inbox |
| Weekly performance summary | Email | In-app digest tile |
| Critical consent/security update | Push + Email | Ops alert + in-app record on next app open |
| Push send failed for high-priority item | Email after delay window | In-app inbox |

---

## 5. UX Principles for Smart Notifications

1. Intent first, then channel.
2. Timing optimization over volume.
3. Positive, age-appropriate language.
4. Parent transparency and preference control.
5. Avoid interruptions during active game sessions.
6. Deep links to exact destination.
7. Explain “why this reminder” where applicable (for trust).

---

## 6. Notification Taxonomy and Policy

Each notification has:
- `type`
- `intent`
- `audience` (`child`, `parent`)
- `priority` (`critical`, `high`, `normal`, `low`)
- `channel` (`push`, `email`, `in_app`)

### 6.1 Initial campaign catalog
| campaign_key | audience | priority | default channels | trigger |
|---|---|---|---|---|
| `learning_reminder_due` | child | normal | push + in_app | inactivity threshold reached |
| `streak_at_risk` | child | high | push + in_app | streak about to break |
| `revision_window_open` | child | high | push + in_app | assessment window in <=72h |
| `learning_pack_ready` | child,parent | normal | push + in_app | pack generation completed |
| `achievement_unlocked` | child,parent | low | in_app + push | milestone reached |
| `weekly_progress_digest` | parent | normal | email | weekly digest scheduler |
| `mastery_alert_parent` | parent | high | email + push(opt-in) | repeated weak performance |
| `consent_or_security_alert` | parent | critical | email + push | consent/security event |

### 6.2 Suppression and fatigue rules
- Child reminders max: 2/day, 6/week.
- Parent non-critical messages max: 1/day, 4/week.
- Dedupe window: 12 hours per `dedupe_key`.
- `dedupe_key = campaign_key + audience + recipient_user_id + child_id(nullable) + channel`.
- No non-critical sends during quiet hours.

### 6.3 Preference precedence and merge algorithm (V1)
Effective preference resolution order:
1. Parent global defaults (`user_id`, `child_id = null`)
2. Child override (`user_id`, `child_id = target child`) only for fields explicitly present
3. Campaign forced policy for legal/security (`critical` only)

Merge rules:
- Scalar fields (`timezone`, `quiet_hours.start_local`, `quiet_hours.end_local`): child value overrides if present.
- Object fields (`channels`, `caps`): merge by key; child keys override only matching keys.
- Missing child fields inherit parent global values.
- Campaign forced policy can bypass non-critical toggles only for `consent_or_security_alert`.

Example:
- Parent defaults: `email=true`, `push=true`, `caps.daily=2`
- Child override: `email=false`
- Effective child config: `email=false`, `push=true`, `caps.daily=2`

---

## 7. End-to-End Triggering and Orchestration

### 7.1 Domain events used
- `SessionCompleted`
- `PackGenerated`
- `AssessmentImported`
- `StreakUpdated`
- `MasteryUpdated`
- `ChildInactiveDetected`
- `ConsentPolicyChanged`

### 7.2 Processing flow
1. Domain event written to event bus/queue.
2. Notification orchestrator loads candidate campaigns.
3. Policy engine checks consent, preferences, caps, quiet hours.
4. Personalization engine renders template tokens.
5. Notification job created with:
   - `dedupe_key = campaign_key + audience + recipient_user_id + child_id(nullable) + channel`
   - `idempotency_key = source_event_id + campaign_key + recipient_user_id + child_id + channel`
6. Channel worker sends through provider adapter.
7. Provider callbacks update delivery/open/click status.
8. Analytics pipeline updates dashboards and experiments.

### 7.3 Priority behavior
- `critical`: bypass quiet hours and non-critical caps.
- `high`: quiet hours respected unless assessment-related within configured window.
- `normal/low`: always respect quiet hours and caps.

### 7.4 Active session interruption gate
- Policy engine input: `is_child_active_in_session`.
- Definition (V1): child considered active if last interaction is <=45 seconds ago.
- If active and campaign priority is `normal` or `low`, defer send to the next eligible window.
- `high` can send while active only for assessment-related windows; `critical` can send immediately.

---

## 8. Backend Architecture (Laravel + Redis + MongoDB)

### 8.1 Components
1. **Notification Orchestrator Service** (Laravel domain module)
2. **Policy Engine** (eligibility, consent, caps, quiet-hour logic)
3. **Template Renderer** (localized copy + token interpolation)
4. **Dispatch Workers** (`notifications_push`, `notifications_email` queues)
5. **Provider Adapters** (FCM/APNs, email provider)
6. **Webhook Receiver** (delivery/open/bounce/unsubscribe updates)
7. **Ledger + Analytics Exporter** (MongoDB + metrics)

### 8.2 Reliability guarantees
- At-least-once dispatch with idempotent `event_id`.
- Retries with exponential backoff + jitter and bounded attempts per channel.
- Dead-letter queue after terminal failure.
- Token hygiene process removes invalid tokens.
- Circuit breaker for provider outage periods.
- Terminal behavior for `critical` campaigns:
  - Try configured channels (`push` + `email`) with bounded retries.
  - If all attempts fail: set `failed_terminal`, stop sending, emit ops alert, and create in-app record on next app open.

### 8.3 Suggested MongoDB collections

#### `notification_preferences`
- `user_id`
- `child_id` (nullable)
- `channels.push.enabled`
- `channels.email.enabled`
- `channels.in_app.enabled`
- `quiet_hours.start_local`
- `quiet_hours.end_local`
- `timezone`
- `caps.daily`
- `caps.weekly`
- `updated_at`

#### `notification_campaigns`
- `campaign_key`
- `type`
- `audience`
- `default_priority`
- `template_refs` (per locale/channel)
- `enabled`
- `policy_overrides`

#### `notification_events`
- `event_id` (idempotency key)
- `source_event_id`
- `campaign_key`
- `audience`
- `recipient_user_id`
- `user_id`
- `child_id`
- `channel`
- `dedupe_key`
- `idempotency_key`
- `status` (`queued`, `sent`, `delivered`, `opened`, `clicked`, `failed`, `failed_terminal`, `suppressed`)
- `suppression_reason` (if any)
- `provider_message_id`
- `scheduled_for`
- `sent_at`
- `failure_reason`
- `failed_terminal_at` (nullable)
- `consent_state`
- `policy_version`
- `context_payload`

#### `device_tokens`
- `token_id`
- `user_id`
- `child_id`
- `platform`
- `token`
- `locale`
- `timezone`
- `last_seen_at`
- `revoked_at`

### 8.4 Suggested indexes and constraints
- `notification_events` unique index on `idempotency_key`.
- `notification_events` index on `dedupe_key` + `scheduled_for`.
- `notification_events` index on `recipient_user_id` + `status` + `sent_at`.
- `notification_events` index on `campaign_key` + `status` + `sent_at`.

---

## 9. API Contracts

### 9.1 Public app APIs
Base rules:
- Prefix: `/api/v1`
- Auth: `auth:api` (JWT)
- Child-scoped ownership: enforce with existing `FindsOwnedChild` pattern

Endpoints:
1. `POST /api/v1/children/{child}/notification-devices`
2. `DELETE /api/v1/children/{child}/notification-devices/{deviceTokenId}`
3. `GET /api/v1/children/{child}/notification-preferences`
4. `PUT /api/v1/children/{child}/notification-preferences`
5. `GET /api/v1/children/{child}/notifications?cursor=...`
6. `POST /api/v1/children/{child}/notifications/{id}/read`
7. `POST /api/v1/children/{child}/notifications/{id}/open` (optional tracking event)
8. `GET /api/v1/notifications/parent-inbox?cursor=...` (parent-facing digest/alerts, self scope)

### 9.2 Internal APIs
- `POST /internal/notifications/trigger`
- `POST /internal/notifications/retry/{eventId}`
- `POST /internal/notifications/simulate` (staging/debug only)

Internal auth:
- Service-to-service signed token.
- Allowlisted internal network or gateway source.
- `simulate` disabled in production.

### 9.3 Example request: update preferences
```json
{
  "globalParentDefaults": {
    "channels": {
      "push": true,
      "email": true,
      "inApp": true
    },
    "quietHours": {
      "startLocal": "20:30",
      "endLocal": "07:00",
      "timezone": "Europe/Amsterdam"
    },
    "caps": {
      "daily": 2,
      "weekly": 6
    }
  },
  "childOverrides": {
    "channels": {
      "email": false
    },
    "caps": {
      "daily": 1
    }
  }
}
```

### 9.4 Response and error contract (V1)
- Success envelope:
```json
{
  "data": {}
}
```
- Error envelope:
```json
{
  "error": {
    "code": "not_found|validation_error|forbidden|unauthorized|rate_limited|conflict|internal_error",
    "message": "Human readable summary",
    "details": {}
  }
}
```
- Common statuses:
  - `200` / `201` success
  - `204` delete/read with no body
  - `400` validation error
  - `401` missing/invalid JWT
  - `403` child ownership violation
  - `404` missing child/notification token
  - `409` idempotency conflict
  - `429` throttled
  - `500` internal failure

### 9.5 Pagination contract (inbox endpoints)
- Cursor-based pagination with `cursor` query parameter.
- Response shape:
```json
{
  "data": [],
  "meta": {
    "nextCursor": "opaque_cursor_or_null"
  }
}
```

---

## 10. Personalization Strategy

### 10.1 Inputs
- Activity recency and session duration.
- Streak state.
- Weak areas and unresolved concepts.
- Upcoming assessments.
- Historical notification engagement.
- Preferred study windows.

### 10.2 Decision examples
- 48h inactivity + preferred window open -> send `learning_reminder_due`.
- Exam within 72h + weak topic unresolved -> send `revision_window_open`.
- 3 ignored reminders this week -> pause child reminder campaign for 48h and mention in parent digest.
- Child currently active in a game + campaign priority `normal` -> defer until active-session gate clears.

### 10.3 Cadence adaptation (MVP)
- Engaged users: keep standard cadence.
- Low engagement: reduce frequency and prioritize higher-value triggers.
- Highly active users: suppress routine reminders, keep milestone notifications.

---

## 11. Content and Template System

### 11.1 Push template schema
- `title`
- `body`
- `deeplink`
- `campaign_key`
- `tokens`
- `ttl_seconds`

### 11.2 Email template structure
- Subject + preheader.
- Parent digest blocks:
  - Wins this week
  - Areas to revisit
  - Recommended next action
- Single clear CTA.

### 11.3 Copy guidelines
- Child copy: short, supportive, action-oriented.
- Parent copy: factual and decision-supportive.
- No blame language; avoid high-pressure urgency except security alerts.

### 11.4 Localization
- Locale variants: `en`, `fr`, `nl` first.
- Fallback chain: child/parent locale -> app locale -> `en`.

---

## 12. Security, Privacy, and Compliance

1. Enforce COPPA/GDPR-K requirements by market.
2. Parent consent checks for child comms where required.
3. Minimize personal data in push payloads.
4. Signed deep links + authenticated route checks.
5. Audit log for preference changes and suppression outcomes.
6. Right-to-delete workflow removes tokens and notification history per policy.

### 12.1 V1 consent matrix (simple)
| Market requires verified parent consent? | Consent state | Child push/email campaigns | Child in-app operational notices | Parent communication |
|---|---|---|---|---|
| No | any | Allowed via normal policy engine | Allowed | Allowed |
| Yes | verified | Allowed via normal policy engine | Allowed | Allowed |
| Yes | missing/unverified | Suppressed for proactive child campaigns | Allowed only while child is active in app | Send `consent_or_security_alert` |

### 12.2 Policy decision traceability
Store the following on every notification decision:
- `consent_state`
- `policy_version`
- `suppression_reason` (if suppressed)

---

## 13. Observability and Analytics

### 13.1 Operational dashboards
- Queue depth and processing latency.
- Send/delivery success by channel/provider.
- Failure reasons by campaign.
- Token invalidation trend.

### 13.2 Product funnel metrics
- Send -> open -> session-start conversion.
- Reminder-to-session conversion within 24h.
- D7/D30 retention impact for exposed vs holdout cohorts.
- Opt-out and unsubscribe rates.

### 13.3 Alerts
- Delivery success <95% over 30 minutes.
- Queue lag >10 minutes for high-priority campaigns.
- Opt-out spike >30% week-over-week.

---

## 14. Experimentation Framework

### 14.1 Early experiments
1. Send window test: 16:00–18:00 vs 18:00–20:00.
2. Copy framing test: “streak” vs “quick revision boost”.
3. Parent digest format test: concise vs detailed.

### 14.2 Measurement
- Primary: session starts within 24h.
- Secondary: 7-day active learning days, opt-outs.
- Guardrail: no significant increase in disable/unsubscribe.

### 14.3 Assignment and contamination guardrails
- Assignment unit:
  - Child campaigns -> `child_id`
  - Parent campaigns -> `recipient_user_id`
- Sticky assignment window: 28 days.
- Parent digest experiments must not modify child reminder cadence.

---

## 15. Rollout Plan

### Phase 1 — Foundation (2–3 sprints)
- Device token registration + revocation.
- Preferences APIs and app integration.
- Push dispatch pipeline.
- Notification ledger and baseline dashboards.

### Phase 2 — Core Smart Campaigns (2 sprints)
- `learning_reminder_due`, `learning_pack_ready`, `weekly_progress_digest`.
- Frequency caps, dedupe, quiet hours.
- Provider webhooks + state transitions.

### Phase 3 — Optimization (ongoing)
- Cadence adaptation and advanced timing optimization.
- Controlled A/B experimentation.
- Cross-channel fallback tuning.

---

## 16. Implementation Tasks (Engineering Backlog)

### 16.1 Backend
1. Create `Notifications` Laravel domain module.
2. Add MongoDB repositories for preferences/events/campaigns/tokens.
3. Implement policy engine and suppression reasons.
4. Build push/email adapter interfaces + first provider implementations.
5. Add queue workers and DLQ handling.
6. Add webhooks endpoint + signature verification.
7. Add indexes/constraints for `idempotency_key` and `dedupe_key`.
8. Implement service-to-service auth for `/internal/notifications/*`.
9. Add active-session signal ingestion and policy gate (`<=45s`).

### 16.2 Mobile app
1. Permission request and device token registration flow.
2. Deep-link routing from notification payloads.
3. Preference UI wiring to backend API.
4. In-app inbox sync and read-state updates.

### 16.3 Data and analytics
1. Define canonical event schema for notification lifecycle.
2. Build retention + conversion dashboards.
3. Add experiment assignment and holdout logic.
4. Persist assignment stickiness and enforce parent/child contamination guardrails.

### 16.4 Validation scenarios (required)
1. Policy and suppression
   - Child campaign suppressed when consent is missing in consent-required market.
   - Non-critical campaigns respect quiet hours and caps.
   - High-priority assessment exception behaves as specified.
   - Active-session deferral delays and later sends once session ends.
2. Dedupe and idempotency
   - Duplicate source event does not generate duplicate sends for same recipient/channel.
   - Parent-only campaigns do not dedupe across different parent users.
3. Preference precedence
   - Parent global default applies when child override is absent.
   - Child override applies only to explicitly provided fields.
   - Critical legal/security campaign override bypasses non-critical toggles only for allowed campaigns.
4. Delivery failure handling
   - Retries follow bounded backoff and set `failed_terminal` on exhaustion.
   - No further send attempts are scheduled after terminal failure.
   - Ops alert emitted for terminal critical failures.
5. Authorization
   - Parent cannot read/write notifications for non-owned child.
   - Parent inbox endpoint returns only authenticated user records.
   - Internal endpoints reject invalid/missing signed service token.
6. Analytics integrity
   - Lifecycle transitions (`queued` -> `sent` -> `delivered/opened/failed/suppressed`) are valid and auditable.
   - Holdout assignment remains sticky for 28 days.

---

## 17. Definition of Done

- Three campaigns live end-to-end:
  - `learning_reminder_due`
  - `learning_pack_ready`
  - `weekly_progress_digest`
- Preferences and quiet hours enforced consistently.
- Delivery/open/failure metrics visible in dashboards.
- Policy tests cover caps, dedupe, quiet hours, consent gating.
- Legal/privacy sign-off completed for child-facing communication.
- Terminal failure flow covered: bounded retries, `failed_terminal`, stop sending, ops alert path.
- API contracts documented with request/response/errors/pagination and ownership auth rules.

---

## 18. Risks and Mitigations

1. **Notification fatigue** -> strict caps, adaptive suppression, and campaign reviews.
2. **Provider lock-in** -> adapter abstraction and neutral internal event model.
3. **Low deliverability** -> token hygiene, retries, fallback channels, alerting.
4. **Regional legal variance** -> market-specific policy configuration and compliance checklist.
5. **Over-suppression due to policy complexity** -> explicit precedence rules + auditability fields (`consent_state`, `policy_version`).

---

## 19. Recommended Next Step

Start Phase 1 with a thin vertical slice:
1. Register token.
2. Trigger `learning_pack_ready` on successful generation.
3. Deliver push + in-app card.
4. Track delivered/opened/session_started metrics.

This gives immediate product value and validates the full backend-to-app notification loop before adding more campaigns.
