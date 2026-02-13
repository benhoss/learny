<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Bound Child Profile (Dev/Staging Only)
    |--------------------------------------------------------------------------
    |
    | When set, API child-scoped routes resolve to this child profile in
    | non-production environments. This is useful for fast local testing while
    | keeping route contracts unchanged.
    |
    */
    'bound_child_profile_id' => env('BOUND_CHILD_PROFILE_ID'),

    /*
    |--------------------------------------------------------------------------
    | Onboarding Compliance Defaults
    |--------------------------------------------------------------------------
    */
    'default_market' => env('LEARNY_DEFAULT_MARKET', 'US'),
    'consent_age_by_market' => [
        'US' => (int) env('LEARNY_CONSENT_AGE_US', 13),
        'FR' => (int) env('LEARNY_CONSENT_AGE_FR', 15),
        'NL' => (int) env('LEARNY_CONSENT_AGE_NL', 16),
    ],

    /*
    |--------------------------------------------------------------------------
    | Notifications
    |--------------------------------------------------------------------------
    */
    'notifications' => [
        'policy_version' => env('NOTIFICATIONS_POLICY_VERSION', 'v1'),
        'internal_token' => env('NOTIFICATIONS_INTERNAL_TOKEN'),
        'internal_allowlist' => array_values(array_filter(array_map(
            static fn (?string $ip): ?string => filled($ip) ? trim($ip) : null,
            explode(',', (string) env('NOTIFICATIONS_INTERNAL_ALLOWLIST', ''))
        ))),
        'dedupe_window_hours' => (int) env('NOTIFICATIONS_DEDUPE_WINDOW_HOURS', 12),
        'active_session_window_seconds' => (int) env('NOTIFICATIONS_ACTIVE_SESSION_WINDOW_SECONDS', 45),
        'defer_seconds' => (int) env('NOTIFICATIONS_DEFER_SECONDS', 60),
        'max_retry_attempts' => (int) env('NOTIFICATIONS_MAX_RETRY_ATTEMPTS', 3),
    ],

    /*
    |--------------------------------------------------------------------------
    | AI Guardrails
    |--------------------------------------------------------------------------
    */
    'ai_guardrails' => [
        'policy_version' => env('LEARNY_AI_GUARDRAILS_POLICY_VERSION', 'v1'),
        'blocked_terms' => (static function (): array {
            $defaults = [
                'kill yourself',
                'how to cheat',
                'build a bomb',
            ];

            $raw = env('LEARNY_AI_GUARDRAILS_BLOCKED_TERMS');
            if (! is_string($raw) || trim($raw) === '') {
                return $defaults;
            }

            $decoded = json_decode($raw, true);
            $terms = is_array($decoded) ? $decoded : explode(',', $raw);

            $normalized = array_map(
                static fn (mixed $term): ?string => is_string($term) ? trim($term) : null,
                $terms
            );

            $filtered = array_values(array_filter(
                $normalized,
                static fn (?string $term): bool => is_string($term) && $term !== ''
            ));

            return $filtered !== [] ? array_values(array_unique($filtered)) : $defaults;
        })(),
    ],

];
