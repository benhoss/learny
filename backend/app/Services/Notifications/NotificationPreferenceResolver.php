<?php

namespace App\Services\Notifications;

use App\Models\NotificationPreference;

class NotificationPreferenceResolver
{
    public function loadResolved(string $userId, string $childId): array
    {
        $global = $this->normalizePreference(
            NotificationPreference::where('user_id', $userId)
                ->whereNull('child_id')
                ->first()?->toArray() ?? []
        );
        $child = $this->normalizePreference(
            NotificationPreference::where('user_id', $userId)
                ->where('child_id', $childId)
                ->first()?->toArray() ?? []
        );

        return [
            'globalParentDefaults' => $global,
            'childOverrides' => $child,
            'effective' => $this->merge($global, $child),
        ];
    }

    public function updateFromPayload(string $userId, string $childId, array $payload): array
    {
        if (array_key_exists('globalParentDefaults', $payload)) {
            $this->upsertPreference($userId, null, $payload['globalParentDefaults'] ?? []);
        }

        if (array_key_exists('childOverrides', $payload)) {
            $this->upsertPreference($userId, $childId, $payload['childOverrides'] ?? []);
        }

        return $this->loadResolved($userId, $childId);
    }

    public function merge(array $global, array $child): array
    {
        $effective = $global;

        foreach (['timezone'] as $key) {
            if (array_key_exists($key, $child)) {
                $effective[$key] = $child[$key];
            }
        }

        foreach (['channels', 'quietHours', 'caps'] as $key) {
            $effective[$key] = array_merge(
                (array) ($global[$key] ?? []),
                (array) ($child[$key] ?? [])
            );
        }

        return $this->normalizePreference($effective);
    }

    protected function upsertPreference(string $userId, ?string $childId, array $raw): void
    {
        $normalized = $this->normalizePreference($raw);

        $preference = NotificationPreference::firstOrNew([
            'user_id' => $userId,
            'child_id' => $childId,
        ]);

        $preference->channels = $normalized['channels'];
        $preference->quiet_hours = $normalized['quietHours'];
        $preference->timezone = $normalized['timezone'];
        $preference->caps = $normalized['caps'];
        $preference->updated_at = now();
        $preference->save();
    }

    protected function normalizePreference(array $raw): array
    {
        $channels = (array) ($raw['channels'] ?? []);
        $quietHours = (array) ($raw['quietHours'] ?? $raw['quiet_hours'] ?? []);
        $caps = (array) ($raw['caps'] ?? []);

        return [
            'channels' => [
                'push' => (bool) ($channels['push'] ?? true),
                'email' => (bool) ($channels['email'] ?? true),
                'inApp' => (bool) ($channels['inApp'] ?? $channels['in_app'] ?? true),
            ],
            'quietHours' => [
                'startLocal' => (string) ($quietHours['startLocal'] ?? $quietHours['start_local'] ?? '20:30'),
                'endLocal' => (string) ($quietHours['endLocal'] ?? $quietHours['end_local'] ?? '07:00'),
            ],
            'timezone' => (string) ($raw['timezone'] ?? 'UTC'),
            'caps' => [
                'daily' => (int) ($caps['daily'] ?? 2),
                'weekly' => (int) ($caps['weekly'] ?? 6),
            ],
        ];
    }
}
