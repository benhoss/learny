<?php

namespace App\Support\Documents;

use App\Models\Document;
use Illuminate\Support\Carbon;

class PipelineTelemetry
{
    public static function transition(Document $document, string $stage, int $progressHint, ?string $status = null): void
    {
        $now = now();
        self::recordPreviousStageDuration($document, $now);

        if ($status !== null) {
            $document->status = $status;
        }

        $document->pipeline_stage = $stage;
        $document->stage_started_at = $now;
        $document->stage_completed_at = null;
        $document->progress_hint = $progressHint;
        $document->stage_history = self::appendHistory($document, $stage, $now);
    }

    public static function complete(Document $document, ?string $status = null, ?string $stage = null, ?int $progressHint = null): void
    {
        $now = now();
        self::recordPreviousStageDuration($document, $now);

        if ($status !== null) {
            $document->status = $status;
        }

        if ($stage !== null) {
            $document->pipeline_stage = $stage;
            $document->stage_history = self::appendHistory($document, $stage, $now);
        }

        if ($progressHint !== null) {
            $document->progress_hint = $progressHint;
        }

        $document->stage_started_at = $now;
        $document->stage_completed_at = $now;
    }

    public static function recordRuntime(Document $document, string $key, int $durationMs): void
    {
        $timings = is_array($document->stage_timings ?? null) ? $document->stage_timings : [];
        $timings[$key] = ((int) ($timings[$key] ?? 0)) + $durationMs;
        $document->stage_timings = $timings;
    }

    private static function recordPreviousStageDuration(Document $document, Carbon $now): void
    {
        $stage = is_string($document->pipeline_stage ?? null) ? $document->pipeline_stage : null;
        $started = $document->stage_started_at;

        if ($stage === null || $stage === '' || $started === null) {
            return;
        }

        $startedAt = $started instanceof Carbon ? $started : Carbon::parse((string) $started);
        $durationMs = max(0, $startedAt->diffInMilliseconds($now));

        $timings = is_array($document->stage_timings ?? null) ? $document->stage_timings : [];
        $timings[$stage] = ((int) ($timings[$stage] ?? 0)) + $durationMs;
        $document->stage_timings = $timings;
    }

    private static function appendHistory(Document $document, string $stage, Carbon $at): array
    {
        $history = is_array($document->stage_history ?? null) ? $document->stage_history : [];
        $history[] = [
            'stage' => $stage,
            'at' => $at->toIso8601String(),
        ];

        return $history;
    }
}
