<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\Game;
use App\Models\QuizSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class QuizSessionController extends Controller
{
    use FindsOwnedChild;

    protected const ACTIVE_STATUSES = ['active', 'paused'];

    public function active(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $session = QuizSession::where('child_profile_id', (string) $child->_id)
            ->whereIn('status', self::ACTIVE_STATUSES)
            ->orderBy('last_interaction_at', 'desc')
            ->first();

        return response()->json([
            'data' => $session ? $this->formatSession($session) : null,
            'idempotent_replay' => false,
        ]);
    }

    public function create(Request $request, string $childId, string $packId, string $gameId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $game = Game::where('_id', $gameId)
            ->where('learning_pack_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        if ((string) ($game->type ?? '') !== 'quiz') {
            throw ValidationException::withMessages([
                'game_id' => ['Quiz sessions are only supported for quiz games.'],
            ]);
        }

        $validated = $request->validate([
            'question_count' => ['required', 'integer', 'min:5', 'max:20'],
        ]);

        $existing = QuizSession::where('child_profile_id', (string) $child->_id)
            ->where('game_id', (string) $game->_id)
            ->whereIn('status', self::ACTIVE_STATUSES)
            ->orderBy('last_interaction_at', 'desc')
            ->first();

        if ($existing) {
            return response()->json([
                'data' => $this->formatSession($existing),
                'idempotent_replay' => true,
            ]);
        }

        $questions = collect($game->payload['questions'] ?? [])
            ->where(fn ($item) => is_array($item))
            ->values()
            ->all();
        $availableCount = count($questions);
        $requestedCount = (int) $validated['question_count'];

        if ($availableCount < $requestedCount) {
            throw ValidationException::withMessages([
                'question_count' => ['Requested question count exceeds available quiz questions.'],
            ]);
        }

        $indices = range(0, $availableCount - 1);
        shuffle($indices);
        $selectedIndices = array_slice($indices, 0, $requestedCount);
        sort($selectedIndices);

        $session = QuizSession::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => (string) $packId,
            'game_id' => (string) $game->_id,
            'status' => 'active',
            'requested_question_count' => $requestedCount,
            'available_question_count' => $availableCount,
            'question_indices' => $selectedIndices,
            'current_index' => 0,
            'correct_count' => 0,
            'results' => [],
            'started_at' => now(),
            'last_interaction_at' => now(),
            'paused_at' => null,
            'completed_at' => null,
        ]);

        return response()->json([
            'data' => $this->formatSession($session),
            'idempotent_replay' => false,
        ], 201);
    }

    public function update(Request $request, string $childId, string $sessionId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $session = QuizSession::where('_id', $sessionId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        if (in_array((string) ($session->status ?? ''), ['completed', 'abandoned'], true)) {
            return response()->json([
                'data' => $this->formatSession($session),
                'idempotent_replay' => true,
            ]);
        }

        $validated = $request->validate([
            'current_index' => ['sometimes', 'integer', 'min:0', 'max:200'],
            'correct_count' => ['sometimes', 'integer', 'min:0', 'max:200'],
            'results' => ['sometimes', 'array', 'max:100'],
            'results.*.correct' => ['required_with:results', 'boolean'],
            'results.*.prompt' => ['nullable', 'string', 'max:500'],
            'results.*.topic' => ['nullable', 'string', 'max:255'],
            'results.*.response' => ['nullable', 'string', 'max:500'],
            'results.*.expected' => ['nullable', 'string', 'max:500'],
            'status' => ['sometimes', 'string', 'in:active,paused,completed,abandoned'],
        ]);

        if (array_key_exists('current_index', $validated)) {
            $session->current_index = (int) $validated['current_index'];
        }
        if (array_key_exists('correct_count', $validated)) {
            $session->correct_count = (int) $validated['correct_count'];
        }
        if (array_key_exists('results', $validated)) {
            $session->results = array_values($validated['results']);
        }

        if (array_key_exists('status', $validated)) {
            $status = (string) $validated['status'];
            $session->status = $status;
            if ($status === 'paused') {
                $session->paused_at = now();
            }
            if ($status === 'completed') {
                $session->completed_at = now();
            }
        }

        $session->last_interaction_at = now();
        $session->save();

        return response()->json([
            'data' => $this->formatSession($session),
            'idempotent_replay' => false,
        ]);
    }

    protected function formatSession(QuizSession $session): array
    {
        return [
            'id' => (string) $session->_id,
            'status' => (string) ($session->status ?? 'active'),
            'learning_pack_id' => (string) ($session->learning_pack_id ?? ''),
            'game_id' => (string) ($session->game_id ?? ''),
            'requested_question_count' => (int) ($session->requested_question_count ?? 0),
            'available_question_count' => (int) ($session->available_question_count ?? 0),
            'question_indices' => array_values($session->question_indices ?? []),
            'current_index' => (int) ($session->current_index ?? 0),
            'correct_count' => (int) ($session->correct_count ?? 0),
            'results' => array_values($session->results ?? []),
            'started_at' => optional($session->started_at)->toISOString(),
            'last_interaction_at' => optional($session->last_interaction_at)->toISOString(),
            'paused_at' => optional($session->paused_at)->toISOString(),
            'completed_at' => optional($session->completed_at)->toISOString(),
        ];
    }
}
