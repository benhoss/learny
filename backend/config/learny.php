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
    | AI Guardrails
    |--------------------------------------------------------------------------
    */
    'ai_guardrails' => [
        'policy_version' => env('LEARNY_AI_GUARDRAILS_POLICY_VERSION', 'v1'),
        'blocked_terms' => [
            'kill yourself',
            'how to cheat',
            'build a bomb',
        ],
    ],

];
