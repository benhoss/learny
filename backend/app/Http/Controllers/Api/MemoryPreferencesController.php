<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\GameResult;
use App\Models\LearningMemoryEvent;
use App\Models\MasteryProfile;
use App\Models\RevisionSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
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
        $child->save();

        return response()->json([
            'data' => [
                'scope' => $scope,
                'deleted' => $deleted,
                'preferences' => $this->formatPreferences($child),
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
}
