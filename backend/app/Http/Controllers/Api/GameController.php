<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use App\Models\Game;
use App\Models\LearningPack;
use App\Services\Schemas\JsonSchemaValidator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class GameController extends Controller
{
    public function index(string $childId, string $packId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $games = Game::where('learning_pack_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $games,
        ]);
    }

    public function store(Request $request, string $childId, string $packId, JsonSchemaValidator $validator): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $pack = LearningPack::where('_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        $data = $request->validate([
            'type' => ['required', 'string', 'in:flashcards,quiz,matching,true_false,fill_blank,ordering,multiple_select,short_answer'],
            'payload' => ['required', 'array'],
        ]);

        $schemaPath = $this->schemaForType($data['type']);
        $validator->validate($data['payload'], $schemaPath);

        $game = Game::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => (string) $pack->_id,
            'type' => $data['type'],
            'schema_version' => 'v1',
            'payload' => $data['payload'],
            'status' => 'ready',
        ]);

        return response()->json([
            'data' => $game,
        ], 201);
    }

    public function show(string $childId, string $packId, string $gameId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $game = Game::where('_id', $gameId)
            ->where('learning_pack_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        return response()->json([
            'data' => $game,
        ]);
    }

    protected function schemaForType(string $type): string
    {
        return match ($type) {
            'flashcards' => storage_path('app/schemas/game_flashcards.json'),
            'quiz' => storage_path('app/schemas/game_quiz.json'),
            'matching' => storage_path('app/schemas/game_matching.json'),
            'true_false' => storage_path('app/schemas/game_true_false.json'),
            'fill_blank' => storage_path('app/schemas/game_fill_blank.json'),
            'ordering' => storage_path('app/schemas/game_ordering.json'),
            'multiple_select' => storage_path('app/schemas/game_multiple_select.json'),
            'short_answer' => storage_path('app/schemas/game_short_answer.json'),
            default => throw ValidationException::withMessages([
                'type' => ['Unsupported game type.'],
            ]),
        };
    }

    protected function findOwnedChild(string $childId): ChildProfile
    {
        $userId = (string) Auth::guard('api')->id();

        return ChildProfile::where('_id', $childId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }
}
