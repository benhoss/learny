<?php

namespace App\Support\Ai;

use App\Models\AiGenerationArtifact;
use App\Models\AiGenerationRun;
use App\Models\AiGuardrailResult;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Str;
use RuntimeException;

class GenerationObservability
{
    public static function startRun(array $attributes): AiGenerationRun
    {
        return AiGenerationRun::create(array_merge([
            'correlation_id' => (string) Str::uuid(),
            'started_at' => now(),
            'final_status' => 'processing',
            'final_risk_score' => 0,
            'metadata' => [],
        ], $attributes));
    }

    public static function recordArtifact(AiGenerationRun $run, string $type, array $payload, ?string $schemaName = null, ?string $schemaVersion = null): void
    {
        $serialized = json_encode($payload, JSON_UNESCAPED_UNICODE);

        if (! is_string($serialized)) {
            throw new RuntimeException('Failed to serialize generation artifact payload.');
        }

        AiGenerationArtifact::create([
            'run_id' => (string) $run->_id,
            'artifact_type' => $type,
            'content_encrypted' => Crypt::encryptString($serialized),
            'content_hash' => hash('sha256', $serialized),
            'schema_name' => $schemaName,
            'schema_version' => $schemaVersion,
            'created_at' => now(),
        ]);
    }

    public static function recordGuardrail(AiGenerationRun $run, string $name, string $version, string $result, int $riskPoints = 0, array $reasonCodes = [], array $details = []): void
    {
        AiGuardrailResult::create([
            'run_id' => (string) $run->_id,
            'check_name' => $name,
            'check_version' => $version,
            'result' => $result,
            'risk_points' => $riskPoints,
            'reason_codes' => array_values(array_unique($reasonCodes)),
            'details_json' => $details,
            'created_at' => now(),
        ]);
    }

    public static function complete(AiGenerationRun $run, string $status, int $riskScore = 0, ?string $errorMessage = null): void
    {
        $run->update([
            'final_status' => $status,
            'final_risk_score' => max(0, min(100, $riskScore)),
            'error_message' => $errorMessage,
            'completed_at' => now(),
        ]);
    }
}
