<?php

namespace App\Http\Controllers\Api;

use App\Models\ChildProfile;
use App\Models\NotificationEvent;
use App\Http\Controllers\Controller;
use App\Services\Notifications\NotificationPolicyEngine;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class InternalNotificationController extends Controller
{
    public function __construct(private readonly NotificationPolicyEngine $policyEngine) {}

    public function trigger(Request $request): JsonResponse
    {
        $payload = $request->validate($this->triggerRules());
        $resolved = $this->resolveRecipientAndScope($payload);
        $channels = $this->normalizeChannels((array) $payload['channels']);
        $policy = $this->policyEngine->evaluate(
            audience: (string) $payload['audience'],
            priority: (string) $payload['priority'],
            channels: $channels,
            consentState: (string) ($payload['consent_state'] ?? 'not_required'),
            market: (string) ($payload['market'] ?? config('learny.default_market', 'US')),
            isChildActiveInSession: (bool) ($payload['is_child_active_in_session'] ?? false),
        );

        $dedupeWindowStart = now()->subHours((int) config('learny.notifications.dedupe_window_hours', 12));
        $created = [];
        $existing = [];

        foreach ($channels as $channel) {
            $dedupeKey = implode('|', [
                $payload['campaign_key'],
                $payload['audience'],
                $resolved['recipient_user_id'],
                $resolved['child_id'] ?? 'none',
                $channel,
            ]);

            $idempotencyKey = implode('|', [
                $payload['source_event_id'],
                $payload['campaign_key'],
                $resolved['recipient_user_id'],
                $resolved['child_id'] ?? 'none',
                $channel,
            ]);

            $existingEvent = NotificationEvent::where('idempotency_key', $idempotencyKey)->first();
            if ($existingEvent) {
                $existing[] = (string) $existingEvent->_id;
                continue;
            }

            $isDuplicate = NotificationEvent::where('dedupe_key', $dedupeKey)
                ->where('created_at', '>=', $dedupeWindowStart)
                ->exists();

            $channelStatus = (array) ($policy['channel_statuses'][$channel] ?? []);

            $event = NotificationEvent::create([
                'event_id' => (string) Str::uuid(),
                'source_event_id' => $payload['source_event_id'],
                'campaign_key' => $payload['campaign_key'],
                'audience' => $payload['audience'],
                'recipient_user_id' => $resolved['recipient_user_id'],
                'user_id' => $resolved['recipient_user_id'],
                'child_id' => $resolved['child_id'],
                'channel' => $channel,
                'dedupe_key' => $dedupeKey,
                'idempotency_key' => $idempotencyKey,
                'status' => $isDuplicate ? 'suppressed' : (string) ($channelStatus['status'] ?? 'queued'),
                'suppression_reason' => $isDuplicate
                    ? 'dedupe_window'
                    : ($channelStatus['suppression_reason'] ?? null),
                'scheduled_for' => $channelStatus['scheduled_for'] ?? null,
                'consent_state' => $policy['consent_state'],
                'policy_version' => $policy['policy_version'],
                'priority' => $payload['priority'],
                'context_payload' => (array) ($payload['context_payload'] ?? []),
            ]);

            $created[] = (string) $event->_id;
        }

        return response()->json([
            'data' => [
                'created' => $created,
                'existing' => $existing,
            ],
        ]);
    }

    public function retry(Request $request, string $eventId): JsonResponse
    {
        $payload = $request->validate([
            'force_fail' => ['nullable', 'boolean'],
        ]);

        $event = NotificationEvent::where('_id', $eventId)->firstOrFail();
        if ((string) $event->status === 'failed_terminal') {
            return response()->json([
                'error' => [
                    'code' => 'conflict',
                    'message' => 'Event already terminally failed.',
                    'details' => (object) [],
                ],
            ], 409);
        }

        $maxAttempts = (int) config('learny.notifications.max_retry_attempts', 3);
        $context = (array) ($event->context_payload ?? []);
        $attempts = (int) ($context['attempts'] ?? 0) + 1;
        $context['attempts'] = $attempts;
        $forceFail = (bool) ($payload['force_fail'] ?? false);

        if ($forceFail && $attempts >= $maxAttempts) {
            $event->status = 'failed_terminal';
            $event->failure_reason = 'retry_exhausted';
            $event->failed_terminal_at = now();
            $event->context_payload = $context;
            $event->save();

            if ((string) $event->priority === 'critical') {
                NotificationEvent::create([
                    'event_id' => (string) Str::uuid(),
                    'source_event_id' => (string) $event->source_event_id,
                    'campaign_key' => 'consent_or_security_alert',
                    'audience' => (string) $event->audience,
                    'recipient_user_id' => (string) $event->recipient_user_id,
                    'user_id' => (string) $event->recipient_user_id,
                    'child_id' => $event->child_id,
                    'channel' => 'in_app',
                    'dedupe_key' => sha1('terminal|'.$event->_id),
                    'idempotency_key' => sha1('terminal-notice|'.$event->_id),
                    'status' => 'queued',
                    'priority' => 'critical',
                    'context_payload' => [
                        'type' => 'terminal_failure_notice',
                        'failed_event_id' => (string) $event->_id,
                    ],
                    'consent_state' => (string) ($event->consent_state ?? 'unknown'),
                    'policy_version' => (string) ($event->policy_version ?? config('learny.notifications.policy_version', 'v1')),
                ]);
            }

            return response()->json([
                'data' => $this->serialize($event->refresh()),
            ]);
        }

        if ($forceFail) {
            $event->status = 'failed';
            $event->failure_reason = 'forced_failure';
            $event->context_payload = $context;
            $event->save();

            return response()->json([
                'data' => $this->serialize($event->refresh()),
            ]);
        }

        $event->status = 'sent';
        $event->sent_at = now();
        $event->failure_reason = null;
        $event->context_payload = $context;
        $event->save();

        return response()->json([
            'data' => $this->serialize($event->refresh()),
        ]);
    }

    public function simulate(Request $request): JsonResponse
    {
        if (app()->environment('production')) {
            return response()->json([
                'error' => [
                    'code' => 'forbidden',
                    'message' => 'Simulation disabled in production.',
                    'details' => (object) [],
                ],
            ], 403);
        }

        $payload = $request->validate($this->triggerRules());
        $channels = $this->normalizeChannels((array) $payload['channels']);
        $policy = $this->policyEngine->evaluate(
            audience: (string) $payload['audience'],
            priority: (string) $payload['priority'],
            channels: $channels,
            consentState: (string) ($payload['consent_state'] ?? 'not_required'),
            market: (string) ($payload['market'] ?? config('learny.default_market', 'US')),
            isChildActiveInSession: (bool) ($payload['is_child_active_in_session'] ?? false),
        );

        return response()->json([
            'data' => [
                'channels' => $channels,
                'policy' => $policy,
            ],
        ]);
    }

    private function resolveRecipientAndScope(array $payload): array
    {
        $audience = (string) $payload['audience'];
        $childId = filled($payload['child_id'] ?? null) ? (string) $payload['child_id'] : null;
        $recipientUserId = filled($payload['recipient_user_id'] ?? null) ? (string) $payload['recipient_user_id'] : null;

        if ($audience === 'child') {
            if ($childId === null) {
                throw ValidationException::withMessages([
                    'child_id' => ['child_id is required for child audience.'],
                ]);
            }

            /** @var ChildProfile $child */
            $child = ChildProfile::where('_id', $childId)->firstOrFail();

            return [
                'recipient_user_id' => $recipientUserId ?: (string) $child->user_id,
                'child_id' => (string) $child->_id,
            ];
        }

        if ($recipientUserId === null) {
            throw ValidationException::withMessages([
                'recipient_user_id' => ['recipient_user_id is required for parent audience.'],
            ]);
        }

        return [
            'recipient_user_id' => $recipientUserId,
            'child_id' => $childId,
        ];
    }

    /**
     * @param  array<int, string>  $channels
     * @return list<string>
     */
    private function normalizeChannels(array $channels): array
    {
        return array_values(array_unique(array_filter(
            array_map(static fn (mixed $channel): string => (string) $channel, $channels),
            static fn (string $channel): bool => in_array($channel, ['push', 'email', 'in_app'], true)
        )));
    }

    private function triggerRules(): array
    {
        return [
            'source_event_id' => ['required', 'string', 'max:100'],
            'campaign_key' => ['required', 'string', 'max:100'],
            'audience' => ['required', Rule::in(['child', 'parent'])],
            'priority' => ['required', Rule::in(['critical', 'high', 'normal', 'low'])],
            'channels' => ['required', 'array', 'min:1'],
            'channels.*' => ['string', Rule::in(['push', 'email', 'in_app'])],
            'recipient_user_id' => ['nullable', 'string'],
            'child_id' => ['nullable', 'string'],
            'consent_state' => ['nullable', Rule::in(['verified', 'missing', 'unverified', 'not_required'])],
            'market' => ['nullable', 'string', 'size:2'],
            'is_child_active_in_session' => ['nullable', 'boolean'],
            'context_payload' => ['nullable', 'array'],
        ];
    }

    private function serialize(NotificationEvent $event): array
    {
        return [
            'id' => (string) $event->_id,
            'status' => (string) $event->status,
            'failureReason' => $event->failure_reason,
            'failedTerminalAt' => optional($event->failed_terminal_at)->toISOString(),
            'sentAt' => optional($event->sent_at)->toISOString(),
            'contextPayload' => (array) ($event->context_payload ?? []),
        ];
    }
}
