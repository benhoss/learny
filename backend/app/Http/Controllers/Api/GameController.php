<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
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
    use FindsOwnedChild;
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

    public function retry(Request $request, string $childId, string $packId, string $gameId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $game = Game::where('_id', $gameId)
            ->where('learning_pack_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        $data = $request->validate([
            'question_indices' => ['required', 'array', 'min:1'],
            'question_indices.*' => ['integer', 'min:0'],
        ]);

        $filtered = $this->filterPayloadByIndices($game->payload ?? [], (string) $game->type, $data['question_indices']);

        if ($filtered === null) {
            throw ValidationException::withMessages([
                'question_indices' => ['Unable to create retry quiz from this game type.'],
            ]);
        }

        $retryGame = Game::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => (string) $packId,
            'type' => $game->type,
            'schema_version' => 'v1',
            'payload' => $filtered,
            'status' => 'ready',
        ]);

        return response()->json([
            'data' => $retryGame,
        ], 201);
    }

    protected function schemaForType(string $type): string
    {
        return match ($type) {
            'flashcards' => resource_path('schemas/game_flashcards.json'),
            'quiz' => resource_path('schemas/game_quiz.json'),
            'matching' => resource_path('schemas/game_matching.json'),
            'true_false' => resource_path('schemas/game_true_false.json'),
            'fill_blank' => resource_path('schemas/game_fill_blank.json'),
            'ordering' => resource_path('schemas/game_ordering.json'),
            'multiple_select' => resource_path('schemas/game_multiple_select.json'),
            'short_answer' => resource_path('schemas/game_short_answer.json'),
            default => throw ValidationException::withMessages([
                'type' => ['Unsupported game type.'],
            ]),
        };
    }

    protected function filterPayloadByIndices(array $payload, string $type, array $indices): ?array
    {
        $indices = array_values(array_unique(array_filter($indices, 'is_int')));
        if ($indices === []) {
            return null;
        }

        $copy = $payload;
        $itemsKey = match ($type) {
            'flashcards' => 'cards',
            'matching' => 'pairs',
            'ordering' => 'items',
            default => 'questions',
        };

        if (! isset($copy[$itemsKey]) || ! is_array($copy[$itemsKey])) {
            return null;
        }

        $items = [];
        foreach ($copy[$itemsKey] as $index => $item) {
            if (in_array($index, $indices, true)) {
                $items[] = $item;
            }
        }

        if ($items === []) {
            return null;
        }

        $copy[$itemsKey] = $items;
        $copy['title'] = ($copy['title'] ?? 'Quick Quiz').' • Retry';
        $copy['intro'] = $copy['intro'] ?? 'Focus on the questions you missed.';

        return $copy;
    }

}
