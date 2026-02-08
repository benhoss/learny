<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\SchoolAssessment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class SchoolAssessmentController extends Controller
{
    use FindsOwnedChild;

    private const SOURCE_OPTIONS = [
        'manual',
        'ocr',
    ];

    public function index(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $items = SchoolAssessment::where('child_profile_id', (string) $child->_id)
            ->orderByDesc('assessed_at')
            ->orderByDesc('_id')
            ->paginate((int) $request->input('per_page', 20));

        return response()->json($items);
    }

    public function store(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $data = $request->validate($this->rules(false));
        $this->validateScoreBounds($data);

        $assessment = SchoolAssessment::create([
            ...$data,
            'child_profile_id' => (string) $child->_id,
        ]);

        return response()->json([
            'data' => $assessment,
        ], 201);
    }

    public function update(Request $request, string $childId, string $assessmentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $assessment = $this->findChildAssessment((string) $child->_id, $assessmentId);

        $data = $request->validate($this->rules(true));

        $candidate = array_merge($assessment->toArray(), $data);
        $this->validateScoreBounds($candidate);

        $assessment->fill($data);
        $assessment->save();

        return response()->json([
            'data' => $assessment,
        ]);
    }

    public function destroy(string $childId, string $assessmentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $assessment = $this->findChildAssessment((string) $child->_id, $assessmentId);

        $assessment->delete();

        return response()->json([
            'message' => 'Deleted.',
        ]);
    }

    private function findChildAssessment(string $childId, string $assessmentId): SchoolAssessment
    {
        return SchoolAssessment::where('_id', $assessmentId)
            ->where('child_profile_id', $childId)
            ->firstOrFail();
    }

    private function validateScoreBounds(array $data): void
    {
        $score = isset($data['score']) ? (float) $data['score'] : null;
        $maxScore = isset($data['max_score']) ? (float) $data['max_score'] : null;

        if ($score !== null && $maxScore !== null && $score > $maxScore) {
            throw ValidationException::withMessages([
                'score' => ['score cannot exceed max_score.'],
            ]);
        }
    }

    private function rules(bool $partial): array
    {
        $s = $partial ? ['sometimes'] : [];

        return [
            'subject' => [...$s, 'required', 'string', 'max:100'],
            'assessment_type' => [...$s, 'required', 'string', 'max:80'],
            'score' => [...$s, 'required', 'numeric', 'min:0', 'max:1000'],
            'max_score' => [...$s, 'required', 'numeric', 'min:1', 'max:1000'],
            'grade' => [...$s, 'nullable', 'string', 'max:20'],
            'assessed_at' => [...$s, 'required', 'date_format:Y-m-d\TH:i:s\Z,Y-m-d'],
            'teacher_note' => [...$s, 'nullable', 'string', 'max:500'],
            'source' => ['sometimes', Rule::in(self::SOURCE_OPTIONS)],
        ];
    }
}
