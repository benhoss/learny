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
| Critical consent/security update | Push + Email | None (must deliver) |
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
- Dedupe window: 12 hours per `campaign_key` + `child_id`.
- No non-critical sends during quiet hours.

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
5. Notification job created with idempotency key.
6. Channel worker sends through provider adapter.
7. Provider callbacks update delivery/open/click status.
8. Analytics pipeline updates dashboards and experiments.

### 7.3 Priority behavior
- `critical`: bypass quiet hours and non-critical caps.
- `high`: quiet hours respected unless assessment-related within configured window.
- `normal/low`: always respect quiet hours and caps.

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
- Retries with exponential backoff + jitter.
- Dead-letter queue after terminal failure.
- Token hygiene process removes invalid tokens.
- Circuit breaker for provider outage periods.

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
- `campaign_key`
- `user_id`
- `child_id`
- `channel`
- `status` (`queued`, `sent`, `delivered`, `opened`, `clicked`, `failed`, `suppressed`)
- `suppression_reason` (if any)
- `provider_message_id`
- `scheduled_for`
- `sent_at`
- `failure_reason`
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

---

## 9. API Contracts

### 9.1 Public app APIs
1. `POST /v1/notifications/device-tokens`
2. `DELETE /v1/notifications/device-tokens/{tokenId}`
3. `GET /v1/notifications/preferences`
4. `PUT /v1/notifications/preferences`
5. `GET /v1/notifications/inbox?cursor=...`
6. `POST /v1/notifications/{id}/read`
7. `POST /v1/notifications/{id}/open` (optional tracking event)

### 9.2 Internal APIs
- `POST /internal/notifications/trigger`
- `POST /internal/notifications/retry/{eventId}`
- `POST /internal/notifications/simulate` (staging/debug only)

### 9.3 Example request: update preferences
```json
{
  "childId": "child_123",
  "channels": {
    "push": true,
    "email": false,
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

### 16.2 Mobile app
1. Permission request and device token registration flow.
2. Deep-link routing from notification payloads.
3. Preference UI wiring to backend API.
4. In-app inbox sync and read-state updates.

### 16.3 Data and analytics
1. Define canonical event schema for notification lifecycle.
2. Build retention + conversion dashboards.
3. Add experiment assignment and holdout logic.

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

---

## 18. Risks and Mitigations

1. **Notification fatigue** -> strict caps, adaptive suppression, and campaign reviews.
2. **Provider lock-in** -> adapter abstraction and neutral internal event model.
3. **Low deliverability** -> token hygiene, retries, fallback channels, alerting.
4. **Regional legal variance** -> market-specific policy configuration and compliance checklist.

---

## 19. Recommended Next Step

Start Phase 1 with a thin vertical slice:
1. Register token.
2. Trigger `learning_pack_ready` on successful generation.
3. Deliver push + in-app card.
4. Track delivered/opened/session_started metrics.

This gives immediate product value and validates the full backend-to-app notification loop before adding more campaigns.
