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
    | Grade Systems & Age Mapping
    |--------------------------------------------------------------------------
    */
    'grade_systems' => [
        'US' => [
            'name' => 'US System',
            'grades' => ['K', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th', '11th', '12th'],
            'age_map' => [
                5 => 'K', 6 => '1st', 7 => '2nd', 8 => '3rd', 9 => '4th', 10 => '5th', 
                11 => '6th', 12 => '7th', 13 => '8th', 14 => '9th', 15 => '10th', 16 => '11th', 17 => '12th'
            ],
        ],
        'FR' => [
            'name' => 'Système Français',
            'grades' => ['CP', 'CE1', 'CE2', 'CM1', 'CM2', '6ème', '5ème', '4ème', '3ème', '2nde', '1ère', 'Terminale'],
            'age_map' => [
                6 => 'CP', 7 => 'CE1', 8 => 'CE2', 9 => 'CM1', 10 => 'CM2', 
                11 => '6ème', 12 => '5ème', 13 => '4ème', 14 => '3ème', 15 => '2nde', 16 => '1ère', 17 => 'Terminale'
            ],
        ],
        'UK' => [
            'name' => 'UK System',
            'grades' => ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8', 'Year 9', 'Year 10', 'Year 11', 'Year 12', 'Year 13'],
            'age_map' => [
                5 => 'Year 1', 6 => 'Year 2', 7 => 'Year 3', 8 => 'Year 4', 9 => 'Year 5', 10 => 'Year 6', 
                11 => 'Year 7', 12 => 'Year 8', 13 => 'Year 9', 14 => 'Year 10', 15 => 'Year 11', 16 => 'Year 12', 17 => 'Year 13'
            ],
        ],
        'NL' => [
            'name' => 'Nederlands Systeem',
            'grades' => ['Groep 3', 'Groep 4', 'Groep 5', 'Groep 6', 'Groep 7', 'Groep 8', 'Brugklas', '2e Klas', '3e Klas', '4e Klas', '5e Klas', '6e Klas'],
            'age_map' => [
                6 => 'Groep 3', 7 => 'Groep 4', 8 => 'Groep 5', 9 => 'Groep 6', 10 => 'Groep 7', 11 => 'Groep 8',
                12 => 'Brugklas', 13 => '2e Klas', 14 => '3e Klas', 15 => '4e Klas', 16 => '5e Klas', 17 => '6e Klas'
            ],
        ],
        'DEFAULT' => [
            'name' => 'International',
            'grades' => ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'],
            'age_map' => [
                6 => 'Grade 1', 7 => 'Grade 2', 8 => 'Grade 3', 9 => 'Grade 4', 10 => 'Grade 5', 
                11 => 'Grade 6', 12 => 'Grade 7', 13 => 'Grade 8', 14 => 'Grade 9', 15 => 'Grade 10', 16 => 'Grade 11', 17 => 'Grade 12'
            ],
        ],
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
