<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class ChildProfileController extends Controller
{
    private const GENDER_OPTIONS = [
        'female',
        'male',
        'non_binary',
        'prefer_not_to_say',
        'self_describe',
    ];

    private const LEARNING_STYLE_OPTIONS = [
        'visual',
        'auditory',
        'reading_writing',
        'hands_on',
        'short_bursts',
    ];

    public function index(): JsonResponse
    {
        $userId = (string) Auth::guard('api')->id();

        return response()->json([
            'data' => ChildProfile::where('user_id', $userId)->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate($this->rules(false));

        $data['user_id'] = (string) Auth::guard('api')->id();

        $profile = ChildProfile::create($data);

        return response()->json([
            'data' => $profile,
        ], 201);
    }

    public function show(string $id): JsonResponse
    {
        $profile = $this->findOwnedProfile($id);

        return response()->json([
            'data' => $profile,
        ]);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $profile = $this->findOwnedProfile($id);

        $data = $request->validate($this->rules(true));

        $profile->fill($data);
        $profile->save();

        return response()->json([
            'data' => $profile,
        ]);
    }

    public function destroy(string $id): JsonResponse
    {
        $profile = $this->findOwnedProfile($id);
        $profile->delete();

        return response()->json([
            'message' => 'Deleted.',
        ]);
    }

    protected function findOwnedProfile(string $id): ChildProfile
    {
        $userId = (string) Auth::guard('api')->id();

        return ChildProfile::where('_id', $id)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    private function rules(bool $partial): array
    {
        $prefix = $partial ? 'sometimes|' : '';

        return [
            'name' => [$prefix.'required', 'string', 'max:100'],
            'grade_level' => [$prefix.'nullable', 'string', 'max:50'],
            'birth_year' => [$prefix.'nullable', 'integer', 'between:2000,2100'],
            'notes' => [$prefix.'nullable', 'string', 'max:500'],
            'school_class' => [$prefix.'nullable', 'string', 'max:50'],
            'preferred_language' => [$prefix.'nullable', 'string', 'max:10', 'regex:/^[a-z]{2,3}(-[A-Z]{2})?$/'],
            'gender' => [$prefix.'nullable', Rule::in(self::GENDER_OPTIONS)],
            'gender_self_description' => [$prefix.'nullable', 'string', 'max:50', 'required_if:gender,self_describe'],
            'learning_style_preferences' => [$prefix.'nullable', 'array'],
            'learning_style_preferences.*' => ['string', Rule::in(self::LEARNING_STYLE_OPTIONS), 'distinct'],
            'support_needs' => [$prefix.'nullable', 'array:attention_support,dyslexia_friendly_mode,larger_text,reduced_clutter_ui,extra_processing_time,other_notes'],
            'support_needs.attention_support' => ['sometimes', 'boolean'],
            'support_needs.dyslexia_friendly_mode' => ['sometimes', 'boolean'],
            'support_needs.larger_text' => ['sometimes', 'boolean'],
            'support_needs.reduced_clutter_ui' => ['sometimes', 'boolean'],
            'support_needs.extra_processing_time' => ['sometimes', 'boolean'],
            'support_needs.other_notes' => ['sometimes', 'nullable', 'string', 'max:300'],
            'confidence_by_subject' => [$prefix.'nullable', 'array'],
            'confidence_by_subject.*.subject' => ['required_with:confidence_by_subject', 'string', 'max:80'],
            'confidence_by_subject.*.confidence_level' => ['required_with:confidence_by_subject', 'integer', 'between:1,5'],
        ];
    }
}
