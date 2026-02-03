<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use App\Models\Game;
use App\Models\GameResult;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class GameResultController extends Controller
{
    public function store(Request $request, string $childId, string $packId, string $gameId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $game = Game::where('_id', $gameId)
            ->where('learning_pack_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        $data = $request->validate([
            'results' => ['required', 'array', 'min:1'],
            'results.*.correct' => ['required', 'boolean'],
            'results.*.prompt' => ['nullable', 'string'],
            'results.*.topic' => ['nullable', 'string'],
            'results.*.response' => ['nullable', 'string'],
            'results.*.expected' => ['nullable', 'string'],
            'score' => ['nullable', 'numeric', 'min:0', 'max:1'],
            'total_questions' => ['nullable', 'integer', 'min:0'],
            'correct_answers' => ['nullable', 'integer', 'min:0'],
            'language' => ['nullable', 'string'],
            'metadata' => ['nullable', 'array'],
            'completed_at' => ['nullable', 'date'],
        ]);

        $results = $data['results'];
        $total = $data['total_questions'] ?? count($results);
        $correct = $data['correct_answers'] ?? collect($results)
            ->where('correct', true)
            ->count();
        $score = $data['score'] ?? ($total > 0 ? $correct / $total : 0.0);

        $record = GameResult::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => (string) $packId,
            'game_id' => (string) $game->_id,
            'game_type' => $game->type,
            'schema_version' => $game->schema_version,
            'game_payload' => $game->payload,
            'results' => $results,
            'score' => $score,
            'total_questions' => $total,
            'correct_answers' => $correct,
            'language' => $data['language'] ?? null,
            'metadata' => $data['metadata'] ?? [],
            'completed_at' => isset($data['completed_at']) ? $data['completed_at'] : now(),
        ]);

        return response()->json([
            'data' => $record,
        ], 201);
    }

    protected function findOwnedChild(string $childId): ChildProfile
    {
        $userId = (string) Auth::guard('api')->id();

        return ChildProfile::where('_id', $childId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }
}
