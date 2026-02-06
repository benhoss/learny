<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use App\Models\MasteryProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class ChildProgressController extends Controller
{
    use FindsOwnedChild;
    public function mastery(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $profiles = MasteryProfile::where('child_profile_id', (string) $child->_id)
            ->orderBy('concept_key')
            ->get();

        return response()->json([
            'data' => $profiles,
        ]);
    }

    public function upsertMastery(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $data = $request->validate([
            'concept_key' => ['required', 'string', 'max:200'],
            'concept_label' => ['nullable', 'string', 'max:200'],
            'mastery_level' => ['nullable', 'numeric', 'min:0', 'max:1'],
            'total_attempts' => ['nullable', 'integer', 'min:0'],
            'correct_attempts' => ['nullable', 'integer', 'min:0'],
            'last_attempt_at' => ['nullable', 'date'],
        ]);

        $totalAttempts = $data['total_attempts'] ?? null;
        $correctAttempts = $data['correct_attempts'] ?? null;

        if ($totalAttempts !== null && $correctAttempts !== null && $correctAttempts > $totalAttempts) {
            throw ValidationException::withMessages([
                'correct_attempts' => ['correct_attempts cannot exceed total_attempts.'],
            ]);
        }

        $profile = MasteryProfile::updateOrCreate(
            [
                'child_profile_id' => (string) $child->_id,
                'concept_key' => $data['concept_key'],
            ],
            array_merge($data, [
                'child_profile_id' => (string) $child->_id,
            ])
        );

        return response()->json([
            'data' => $profile,
        ], 201);
    }

    public function progress(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $profiles = MasteryProfile::where('child_profile_id', (string) $child->_id)->get();
        $totalConcepts = $profiles->count();
        $averageMastery = $totalConcepts === 0
            ? 0
            : round($profiles->avg('mastery_level') ?? 0, 3);
        $masteredCount = $profiles->filter(function (MasteryProfile $profile) {
            return ($profile->mastery_level ?? 0) >= 0.8;
        })->count();

        return response()->json([
            'data' => [
                'child_id' => (string) $child->_id,
                'total_concepts' => $totalConcepts,
                'mastered_concepts' => $masteredCount,
                'average_mastery' => $averageMastery,
            ],
        ]);
    }

}
