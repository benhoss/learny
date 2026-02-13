<?php

namespace App\Services\Safety;

use JsonException;

class GenerationSafetyGuard
{
    public function evaluate(array $payload): array
    {
        $blockedTerms = array_values(array_filter(
            config('learny.ai_guardrails.blocked_terms', []),
            fn (mixed $term) => is_string($term) && $term !== ''
        ));

        try {
            $serializedPayload = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
        } catch (JsonException $e) {
            return [
                'result' => 'fail',
                'risk_points' => 100,
                'reason_codes' => ['payload_serialization_failed'],
                'details' => [
                    'message' => $e->getMessage(),
                ],
            ];
        }

        $serialized = strtolower($serializedPayload);
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
