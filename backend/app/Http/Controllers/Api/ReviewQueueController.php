<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\MasteryProfile;
use Illuminate\Http\JsonResponse;

class ReviewQueueController extends Controller
{
    use FindsOwnedChild;

    public function index(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $due = MasteryProfile::where('child_profile_id', (string) $child->_id)
            ->where('next_review_at', '<=', now())
            ->orderBy('next_review_at', 'asc')
            ->limit(20)
            ->get(['concept_key', 'concept_label', 'mastery_level', 'next_review_at']);

        return response()->json([
            'data' => $due,
            'total_due' => $due->count(),
            'meta' => [
                'total_due' => $due->count(),
            ],
        ]);
    }
}
