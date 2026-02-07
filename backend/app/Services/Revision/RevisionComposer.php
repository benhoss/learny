<?php

namespace App\Services\Revision;

use App\Models\ChildProfile;
use App\Models\GameResult;
use App\Models\LearningPack;
use App\Models\MasteryProfile;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class RevisionComposer
{
    public function compose(ChildProfile $child, int $limit = 5): array
    {
        $limit = max(3, min(10, $limit));
        $childId = (string) $child->_id;

        $conceptPool = $this->buildConceptPool($childId);

        $items = collect();

        $items = $items->concat($this->fromDueReviewQueue($childId, $conceptPool, max(1, (int) floor($limit / 2))));
        $items = $items->concat($this->fromRecentMistakes($childId, $conceptPool, $limit));
        $items = $items->concat($this->fromRecentPackConcepts($childId, $conceptPool, $limit));

        return $items
            ->unique(fn (array $item) => $item['source'].'::'.$item['concept_key'].'::'.$item['prompt'])
            ->sortByDesc(fn (array $item) => (int) ($item['priority_score'] ?? 0))
            ->take($limit)
            ->values()
            ->all();
    }

    protected function buildConceptPool(string $childId): Collection
    {
        $fromMastery = MasteryProfile::where('child_profile_id', $childId)
            ->orderBy('concept_key')
            ->get(['concept_key', 'concept_label'])
            ->map(fn (MasteryProfile $profile) => [
                'key' => (string) $profile->concept_key,
                'label' => (string) ($profile->concept_label ?: $profile->concept_key),
            ]);

        $fromPacks = LearningPack::where('child_profile_id', $childId)
            ->orderBy('created_at', 'desc')
            ->limit(8)
            ->get(['content'])
            ->flatMap(function (LearningPack $pack) {
                $concepts = $pack->content['concepts'] ?? [];

                return collect($concepts)->map(function ($concept) {
                    $key = (string) ($concept['key'] ?? $concept['concept_key'] ?? '');
                    $label = (string) ($concept['label'] ?? $key);

                    return [
                        'key' => $key,
                        'label' => $label,
                    ];
                });
            });

        return $fromMastery
            ->concat($fromPacks)
            ->filter(fn (array $concept) => $concept['key'] !== '')
            ->unique('key')
            ->values();
    }

    protected function fromDueReviewQueue(string $childId, Collection $conceptPool, int $limit): Collection
    {
        $profiles = MasteryProfile::where('child_profile_id', $childId)
            ->where('next_review_at', '<=', now())
            ->orderBy('next_review_at')
            ->limit($limit)
            ->get(['concept_key', 'concept_label']);

        return $profiles->map(function (MasteryProfile $profile) use ($conceptPool) {
            $label = (string) ($profile->concept_label ?: $profile->concept_key);
            $options = $this->buildOptions($conceptPool, $label);

            return [
                'id' => (string) Str::uuid(),
                'source' => 'review_queue',
                'concept_key' => (string) $profile->concept_key,
                'concept_label' => $label,
                'prompt' => 'Which concept should you review now?',
                'options' => $options,
                'correct_index' => max(0, (int) array_search($label, $options, true)),
                'selection_reason' => 'Due now in your review queue',
                'confidence' => 0.95,
                'priority_score' => 100,
                'explainability' => [
                    'reasons' => ['due_review', 'spaced_repetition'],
                ],
            ];
        });
    }

    protected function fromRecentMistakes(string $childId, Collection $conceptPool, int $limit): Collection
    {
        $results = GameResult::where('child_profile_id', $childId)
            ->orderBy('completed_at', 'desc')
            ->limit(20)
            ->get(['results']);

        $items = collect();

        foreach ($results as $result) {
            foreach (($result->results ?? []) as $entry) {
                if (($entry['correct'] ?? true) !== false) {
                    continue;
                }

                $prompt = trim((string) ($entry['prompt'] ?? ''));
                $expected = trim((string) ($entry['expected'] ?? ''));
                $response = trim((string) ($entry['response'] ?? ''));
                $topic = trim((string) ($entry['topic'] ?? ''));

                if ($prompt === '' || $expected === '') {
                    continue;
                }

                $options = collect([$expected, $response])
                    ->filter(fn (string $option) => $option !== '')
                    ->push('Not sure yet')
                    ->unique()
                    ->values()
                    ->all();

                if (count($options) < 2) {
                    $options = $this->buildOptions($conceptPool, $expected);
                }

                $items->push([
                    'id' => (string) Str::uuid(),
                    'source' => 'recent_mistake',
                    'concept_key' => $topic,
                    'concept_label' => $topic !== '' ? $topic : 'Recent mistake',
                    'prompt' => $prompt,
                    'options' => $options,
                    'correct_index' => max(0, (int) array_search($expected, $options, true)),
                    'selection_reason' => 'Based on a recent wrong answer',
                    'confidence' => 0.9,
                    'priority_score' => 90,
                    'explainability' => [
                        'reasons' => ['recent_mistake', 'needs_reinforcement'],
                    ],
                ]);
            }
        }

        return $items->take($limit)->values();
    }

    protected function fromRecentPackConcepts(string $childId, Collection $conceptPool, int $limit): Collection
    {
        $packs = LearningPack::where('child_profile_id', $childId)
            ->orderBy('created_at', 'desc')
            ->limit(4)
            ->get(['document_id', 'content']);

        $items = collect();

        foreach ($packs as $pack) {
            $concepts = collect($pack->content['concepts'] ?? [])
                ->map(function ($concept) use ($pack) {
                    $key = (string) ($concept['key'] ?? $concept['concept_key'] ?? '');
                    $label = (string) ($concept['label'] ?? $key);

                    return [
                        'key' => $key,
                        'label' => $label,
                        'document_id' => (string) ($pack->document_id ?? ''),
                    ];
                })
                ->filter(fn (array $concept) => $concept['key'] !== '')
                ->take(3);

            foreach ($concepts as $concept) {
                $options = $this->buildOptions($conceptPool, $concept['label']);

                $items->push([
                    'id' => (string) Str::uuid(),
                    'source' => 'recent_pack',
                    'concept_key' => $concept['key'],
                    'concept_label' => $concept['label'],
                    'prompt' => 'Pick the concept from your recent upload.',
                    'options' => $options,
                    'correct_index' => max(0, (int) array_search($concept['label'], $options, true)),
                    'document_id' => $concept['document_id'],
                    'selection_reason' => 'From your latest uploaded document',
                    'confidence' => 0.75,
                    'priority_score' => 70,
                    'explainability' => [
                        'reasons' => ['recent_upload', 'fresh_content'],
                    ],
                ]);
            }
        }

        return $items->take($limit)->values();
    }

    protected function buildOptions(Collection $conceptPool, string $correct): array
    {
        $distractors = $conceptPool
            ->pluck('label')
            ->filter(fn ($label) => is_string($label) && $label !== '' && $label !== $correct)
            ->shuffle()
            ->take(3)
            ->values()
            ->all();

        return collect([$correct, ...$distractors])
            ->shuffle()
            ->values()
            ->all();
    }
}
