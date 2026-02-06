<?php

namespace App\Services\Memory;

use App\Models\Document;
use App\Models\LearningMemoryEvent;
use App\Models\MasteryProfile;

class MemorySignalProjector
{
    public function buildRecommendations(string $childId): array
    {
        $recommendations = [];

        $due = MasteryProfile::where('child_profile_id', $childId)
            ->where('next_review_at', '<=', now())
            ->orderBy('next_review_at')
            ->limit(3)
            ->get(['concept_key', 'concept_label', 'next_review_at']);

        foreach ($due as $profile) {
            $label = (string) ($profile->concept_label ?: $profile->concept_key);
            $recommendations[] = [
                'id' => 'due:'.$profile->concept_key,
                'type' => 'review_due',
                'title' => 'Review now: '.$label,
                'subtitle' => 'This concept is due for spaced revision.',
                'concept_key' => (string) $profile->concept_key,
                'priority_score' => 100,
                'action' => 'start_revision',
                'explainability' => [
                    'source' => 'mastery_profiles.next_review_at',
                    'due_at' => optional($profile->next_review_at)->toISOString(),
                ],
            ];
        }

        $recentMistakes = LearningMemoryEvent::where('child_profile_id', $childId)
            ->where('occurred_at', '>=', now()->subDays(14))
            ->whereIn('event_type', ['play', 'review'])
            ->where('metadata.correct', false)
            ->orderBy('occurred_at', 'desc')
            ->limit(100)
            ->get(['concept_key']);

        $mistakeBuckets = collect($recentMistakes)
            ->groupBy('concept_key')
            ->map(fn ($entries) => $entries->count())
            ->sortDesc()
            ->take(2);

        foreach ($mistakeBuckets as $conceptKey => $count) {
            if (! is_string($conceptKey) || $conceptKey === '') {
                continue;
            }
            $recommendations[] = [
                'id' => 'mistake:'.$conceptKey,
                'type' => 'weak_area',
                'title' => 'Practice weak area',
                'subtitle' => $conceptKey.' had '.$count.' recent mistakes.',
                'concept_key' => $conceptKey,
                'priority_score' => 90,
                'action' => 'start_revision',
                'explainability' => [
                    'source' => 'learning_memory_events',
                    'recent_mistake_count' => $count,
                    'window_days' => 14,
                ],
            ];
        }

        $recentDocument = Document::where('child_profile_id', $childId)
            ->where('status', 'ready')
            ->orderBy('created_at', 'desc')
            ->first(['_id', 'original_filename', 'subject']);

        if ($recentDocument) {
            $recommendations[] = [
                'id' => 'recent-doc:'.(string) $recentDocument->_id,
                'type' => 'recent_upload',
                'title' => 'Continue latest upload',
                'subtitle' => (string) ($recentDocument->subject ?: $recentDocument->original_filename),
                'concept_key' => null,
                'priority_score' => 70,
                'action' => 'start_learning',
                'explainability' => [
                    'source' => 'documents',
                    'document_id' => (string) $recentDocument->_id,
                ],
            ];
        }

        return collect($recommendations)
            ->sortByDesc('priority_score')
            ->take(5)
            ->values()
            ->all();
    }
}
