<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Services\Memory\MemorySignalProjector;
use Illuminate\Http\JsonResponse;

class HomeRecommendationController extends Controller
{
    use FindsOwnedChild;

    public function index(string $childId, MemorySignalProjector $projector): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $recommendations = $projector->buildRecommendations((string) $child->_id);

        return response()->json([
            'data' => $recommendations,
        ]);
    }
}
