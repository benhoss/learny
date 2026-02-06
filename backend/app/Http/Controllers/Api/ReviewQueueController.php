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

        $dueQuery = MasteryProfile::where('child_profile_id', (string) $child->_id)
            ->where('next_review_at', '<=', now());
        $totalDue = (clone $dueQuery)->count();

        $due = $dueQuery
            ->orderBy('next_review_at', 'asc')
            ->limit(20)
            ->get(['concept_key', 'concept_label', 'mastery_level', 'next_review_at']);

        return response()->json([
            'data' => $due,
            'total_due' => $totalDue,
            'meta' => [
                'total_due' => $totalDue,
                'limit' => 20,
            ],
        ]);
    }
}
