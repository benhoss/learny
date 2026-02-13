<?php

namespace App\Services\Notifications;

class NotificationPolicyEngine
{
    /**
     * @param  list<string>  $channels
     * @return array{
     *   channel_statuses: array<string, array{status: string, suppression_reason: ?string, scheduled_for: ?\Carbon\Carbon}>,
     *   consent_state: string,
     *   policy_version: string
     * }
     */
    public function evaluate(
        string $audience,
        string $priority,
        array $channels,
        string $consentState,
        string $market,
        bool $isChildActiveInSession
    ): array {
        $requiresConsent = array_key_exists(
            strtoupper($market),
            (array) config('learny.consent_age_by_market', [])
        );
        $policyVersion = (string) config('learny.notifications.policy_version', 'v1');
        $deferSeconds = (int) config('learny.notifications.defer_seconds', 60);

        $channelStatuses = [];
        foreach ($channels as $channel) {
            $channelStatuses[$channel] = [
                'status' => 'queued',
                'suppression_reason' => null,
                'scheduled_for' => null,
            ];
        }

        if ($audience === 'child' && $requiresConsent && $consentState !== 'verified') {
            foreach ($channels as $channel) {
                if ($channel === 'push' || $channel === 'email') {
                    $channelStatuses[$channel] = [
                        'status' => 'suppressed',
                        'suppression_reason' => 'consent_missing',
                        'scheduled_for' => null,
                    ];
                }

                if ($channel === 'in_app' && ! $isChildActiveInSession) {
                    $channelStatuses[$channel] = [
                        'status' => 'suppressed',
                        'suppression_reason' => 'consent_missing_inactive',
                        'scheduled_for' => null,
                    ];
                }
            }
        }

        if ($isChildActiveInSession && in_array($priority, ['normal', 'low'], true)) {
            foreach ($channels as $channel) {
                if (($channelStatuses[$channel]['status'] ?? null) === 'queued') {
                    $channelStatuses[$channel]['scheduled_for'] = now()->addSeconds($deferSeconds);
                }
            }
        }

        return [
            'channel_statuses' => $channelStatuses,
            'consent_state' => $consentState,
            'policy_version' => $policyVersion,
        ];
    }
}
