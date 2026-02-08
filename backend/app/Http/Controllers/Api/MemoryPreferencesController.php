<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\GameResult;
use App\Models\LearningMemoryEvent;
use App\Models\MasteryProfile;
use App\Models\RevisionSession;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Validation\Rule;

class MemoryPreferencesController extends Controller
{
    use FindsOwnedChild;

    public function show(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        return response()->json([
            'data' => $this->formatPreferences($child),
        ]);
    }

    public function update(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $data = $request->validate([
            'memory_personalization_enabled' => ['sometimes', 'boolean'],
            'recommendation_why_enabled' => ['sometimes', 'boolean'],
            'recommendation_why_level' => ['sometimes', 'string', Rule::in(['brief', 'detailed'])],
        ]);

        $child->fill($data);
        $child->save();

        return response()->json([
            'data' => $this->formatPreferences($child),
        ]);
    }

    public function clearScope(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $data = $request->validate([
            'scope' => ['required', 'string', Rule::in([
                'events',
                'revision_sessions',
                'game_results',
                'mastery_profiles',
                'all',
            ])],
        ]);

        $scope = (string) $data['scope'];
        $childIdValue = (string) $child->_id;
        $deleted = [
            'learning_memory_events' => 0,
            'revision_sessions' => 0,
            'game_results' => 0,
            'mastery_profiles' => 0,
        ];

        if ($scope === 'events' || $scope === 'all') {
            $deleted['learning_memory_events'] = LearningMemoryEvent::where('child_profile_id', $childIdValue)->delete();
        }

        if ($scope === 'revision_sessions' || $scope === 'all') {
            $deleted['revision_sessions'] = RevisionSession::where('child_profile_id', $childIdValue)->delete();
        }

        if ($scope === 'game_results' || $scope === 'all') {
            $deleted['game_results'] = GameResult::where('child_profile_id', $childIdValue)->delete();
        }

        if ($scope === 'mastery_profiles' || $scope === 'all') {
            $deleted['mastery_profiles'] = MasteryProfile::where('child_profile_id', $childIdValue)->delete();
        }

        $child->last_memory_reset_scope = $scope;
        $child->last_memory_reset_at = now();
        $childStats = $this->reconcileChildStatsFromRemainingResults($child, $childIdValue);
        $child->save();

        return response()->json([
            'data' => [
                'scope' => $scope,
                'deleted' => $deleted,
                'preferences' => $this->formatPreferences($child),
                'child_summary' => $childStats,
            ],
        ]);
    }

    protected function formatPreferences($child): array
    {
        return [
            'memory_personalization_enabled' => (bool) ($child->memory_personalization_enabled ?? true),
            'recommendation_why_enabled' => (bool) ($child->recommendation_why_enabled ?? true),
            'recommendation_why_level' => (string) ($child->recommendation_why_level ?: 'detailed'),
            'last_memory_reset_at' => optional($child->last_memory_reset_at)->toISOString(),
            'last_memory_reset_scope' => $child->last_memory_reset_scope ? (string) $child->last_memory_reset_scope : null,
        ];
    }

    protected function reconcileChildStatsFromRemainingResults($child, string $childId): array
    {
        $results = GameResult::where('child_profile_id', $childId)->get(['completed_at', 'xp_earned']);
        $dates = $results->pluck('completed_at')
            ->map(fn ($value) => $value ? Carbon::parse($value)->toDateString() : null)
            ->filter()
            ->unique()
            ->sort()
            ->values();

        $child->total_xp = (int) $results->sum(fn ($result) => (int) ($result->xp_earned ?? 0));
        $child->last_activity_date = $dates->isNotEmpty() ? (string) $dates->last() : null;
        $child->streak_days = $this->computeCurrentStreak($dates);
        $child->longest_streak = $this->computeLongestStreak($dates);

        return [
            'streak_days' => (int) ($child->streak_days ?? 0),
            'longest_streak' => (int) ($child->longest_streak ?? 0),
            'total_xp' => (int) ($child->total_xp ?? 0),
            'last_activity_date' => $child->last_activity_date ? (string) $child->last_activity_date : null,
        ];
    }

    protected function computeCurrentStreak(Collection $dates): int
    {
        if ($dates->isEmpty()) {
            return 0;
        }

        $dateSet = $dates->flip();
        $cursor = now()->toDateString();
        $streak = 0;

        while ($dateSet->has($cursor)) {
            $streak += 1;
            $cursor = Carbon::parse($cursor)->subDay()->toDateString();
        }

        return $streak;
    }

    protected function computeLongestStreak(Collection $dates): int
    {
        if ($dates->isEmpty()) {
            return 0;
        }

        $longest = 0;
        $current = 0;
        $previous = null;

        foreach ($dates as $date) {
            $currentDate = Carbon::parse((string) $date);
            if ($previous && $currentDate->diffInDays($previous) === 1) {
                $current += 1;
            } else {
                $current = 1;
            }

            $longest = max($longest, $current);
            $previous = $currentDate;
        }

        return $longest;
    }
}
