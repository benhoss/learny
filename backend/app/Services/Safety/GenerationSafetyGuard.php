<?php

namespace App\Services\Safety;

class GenerationSafetyGuard
{
    public function evaluate(array $payload): array
    {
        $blockedTerms = array_values(array_filter(
            config('learny.ai_guardrails.blocked_terms', []),
            fn (mixed $term) => is_string($term) && $term !== ''
        ));

        $serialized = strtolower(json_encode($payload, JSON_UNESCAPED_UNICODE));
        $matches = [];

        foreach ($blockedTerms as $term) {
            if (str_contains($serialized, strtolower($term))) {
                $matches[] = $term;
            }
        }

        if ($matches === []) {
            return [
                'result' => 'pass',
                'risk_points' => 0,
                'reason_codes' => [],
                'details' => [],
            ];
        }

        return [
            'result' => 'fail',
            'risk_points' => 80,
            'reason_codes' => ['unsafe_content_detected'],
            'details' => [
                'matched_terms' => array_values(array_unique($matches)),
            ],
        ];
    }
}
