<?php

namespace App\Services\Memory;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\LearningMemoryEvent;
use App\Models\MasteryProfile;
use App\Services\Translator;
use Carbon\Carbon;
use Carbon\CarbonInterface;

class MemorySignalProjector
{
    public function buildRecommendations(ChildProfile $child): array
    {
        $t = Translator::forChild($child);
        $childId = (string) $child->_id;
        $personalizationEnabled = (bool) ($child->memory_personalization_enabled ?? true);
        $includeWhy = (bool) ($child->recommendation_why_enabled ?? true);

        $recommendations = [];

        if ($personalizationEnabled) {
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
                    'title' => $t->get('recommendation.review_title', ['label' => $label]),
                    'subtitle' => $t->get('recommendation.review_subtitle'),
                    'concept_key' => (string) $profile->concept_key,
                    'priority_score' => 100,
                    'action' => 'start_revision',
                    'action_payload' => [
                        'concept_key' => (string) $profile->concept_key,
                        'intent' => 'due_review',
                    ],
                    'explainability' => $includeWhy
                        ? [
                            'source' => 'mastery_profiles.next_review_at',
                            'due_at' => optional($profile->next_review_at)->toISOString(),
                        ]
                        : null,
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
                    'title' => $t->get('recommendation.weak_title'),
                    'subtitle' => $t->get('recommendation.weak_subtitle', ['concept' => $conceptKey, 'count' => $count]),
                    'concept_key' => $conceptKey,
                    'priority_score' => 90,
                    'action' => 'start_revision',
                    'action_payload' => [
                        'concept_key' => $conceptKey,
                        'intent' => 'weak_area',
                    ],
                    'explainability' => $includeWhy
                        ? [
                            'source' => 'learning_memory_events',
                            'recent_mistake_count' => $count,
                            'window_days' => 14,
                        ]
                        : null,
                ];
            }
        }

        $recentDocument = Document::where('child_profile_id', $childId)
            ->where('status', 'ready')
            ->orderBy('created_at', 'desc')
            ->first(['_id', 'original_filename', 'subject']);

        if ($recentDocument) {
            $recommendations[] = [
                'id' => 'recent-doc:'.(string) $recentDocument->_id,
                'type' => 'recent_upload',
                'title' => $t->get('recommendation.recent_upload_title'),
                'subtitle' => (string) ($recentDocument->subject ?: $recentDocument->original_filename),
                'concept_key' => null,
                'priority_score' => 70,
                'action' => 'resume_recent_upload',
                'action_payload' => [
                    'document_id' => (string) $recentDocument->_id,
                ],
                'explainability' => $includeWhy
                    ? [
                        'source' => 'documents',
                        'document_id' => (string) $recentDocument->_id,
                    ]
                    : null,
            ];
        }

        if ($this->shouldRescueStreak($child)) {
            $recommendations[] = [
                'id' => 'streak-rescue:'.$childId,
                'type' => 'streak_rescue',
                'title' => $t->get('recommendation.streak_title'),
                'subtitle' => $t->get('recommendation.streak_subtitle'),
                'concept_key' => null,
                'priority_score' => 95,
                'action' => 'start_streak_rescue',
                'action_payload' => [
                    'target_minutes' => 2,
                ],
                'explainability' => $includeWhy
                    ? [
                        'source' => 'child_profiles',
                        'streak_days' => (int) ($child->streak_days ?? 0),
                        'last_activity_date' => optional($this->parseDate($child->last_activity_date))->toISOString(),
                    ]
                    : null,
            ];
        }

        if (! $personalizationEnabled) {
            $recommendations[] = [
                'id' => 'generic:resume',
                'type' => 'generic_practice',
                'title' => $t->get('recommendation.generic_title'),
                'subtitle' => $t->get('recommendation.generic_subtitle'),
                'concept_key' => null,
                'priority_score' => 80,
                'action' => 'start_learning',
                'action_payload' => null,
                'explainability' => $includeWhy ? ['source' => 'memory_preferences'] : null,
            ];
        }

        return collect($recommendations)
            ->sortByDesc('priority_score')
            ->take(5)
            ->values()
            ->all();
    }

    protected function shouldRescueStreak(ChildProfile $child): bool
    {
        $streak = (int) ($child->streak_days ?? 0);
        if ($streak <= 0) {
            return false;
        }

        $lastActivity = $this->parseDate($child->last_activity_date);

        return $lastActivity !== null && $lastActivity->lt(now()->subDay());
    }

    protected function parseDate(mixed $value): ?CarbonInterface
    {
        if ($value instanceof CarbonInterface) {
            return $value;
        }

        if (is_string($value) && $value !== '') {
            try {
                return Carbon::parse($value);
            } catch (\Throwable) {
                return null;
            }
        }

        return null;
    }
}
