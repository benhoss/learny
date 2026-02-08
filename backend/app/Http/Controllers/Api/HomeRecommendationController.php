<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\LearningMemoryEvent;
use App\Services\Memory\MemorySignalProjector;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class HomeRecommendationController extends Controller
{
    use FindsOwnedChild;

    public function index(string $childId, MemorySignalProjector $projector): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $recommendations = $projector->buildRecommendations($child);

        return response()->json([
            'data' => $recommendations,
        ]);
    }

    public function track(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $payload = $request->validate([
            'recommendation_id' => ['required', 'string', 'max:200'],
            'recommendation_type' => ['nullable', 'string', 'max:100'],
            'action' => ['nullable', 'string', 'max:100'],
            'event' => ['nullable', 'string', 'max:50'],
            'metadata' => ['nullable', 'array'],
        ]);

        $event = (string) ($payload['event'] ?? 'tap');
        $recommendationId = (string) $payload['recommendation_id'];
        $eventKey = sha1('home-recommendation:'.(string) $child->_id.':'.$event.':'.$recommendationId.':'.Str::uuid());
        $eventOrder = $this->nextEventOrder((string) $child->_id);

        LearningMemoryEvent::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'concept_key' => (string) ($payload['recommendation_type'] ?? 'home_recommendation'),
            'event_type' => 'recommendation',
            'event_key' => $eventKey,
            'event_order' => $eventOrder,
            'source_type' => 'home_recommendation',
            'source_id' => $recommendationId,
            'occurred_at' => now(),
            'confidence' => 0.6,
            'metadata' => array_merge([
                'event' => $event,
                'action' => (string) ($payload['action'] ?? ''),
                'recommendation_type' => (string) ($payload['recommendation_type'] ?? ''),
            ], $payload['metadata'] ?? []),
        ]);

        return response()->json([
            'data' => [
                'recorded' => true,
                'event_key' => $eventKey,
            ],
        ]);
    }

    protected function nextEventOrder(string $childId): int
    {
        $maxOrder = LearningMemoryEvent::where('child_profile_id', $childId)->max('event_order');

        return is_numeric($maxOrder) ? ((int) $maxOrder + 1) : 1;
    }
}
