<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class ChildProfileController extends Controller
{
    use FindsOwnedChild;
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
        $profile = $this->findOwnedChild($id);

        return response()->json([
            'data' => $profile,
        ]);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $profile = $this->findOwnedChild($id);

        $data = $request->validate($this->rules(true));

        $profile->fill($data);
        $profile->save();

        return response()->json([
            'data' => $profile,
        ]);
    }

    public function destroy(string $id): JsonResponse
    {
        $profile = $this->findOwnedChild($id);
        $profile->delete();

        return response()->json([
            'message' => 'Deleted.',
        ]);
    }

    private function rules(bool $partial): array
    {
        $s = $partial ? ['sometimes'] : [];

        return [
            'name' => [...$s, 'required', 'string', 'max:100'],
            'grade_level' => [...$s, 'nullable', 'string', 'max:50'],
            'birth_year' => [...$s, 'nullable', 'integer', 'between:2000,2100'],
            'notes' => [...$s, 'nullable', 'string', 'max:500'],
            'school_class' => [...$s, 'nullable', 'string', 'max:50'],
            'preferred_language' => [...$s, 'nullable', 'string', Rule::in(['en', 'fr', 'nl'])],
            'gender' => [...$s, 'nullable', Rule::in(self::GENDER_OPTIONS)],
            'gender_self_description' => [...$s, 'nullable', 'string', 'max:50', 'required_if:gender,self_describe', 'prohibited_unless:gender,self_describe'],
            'learning_style_preferences' => [...$s, 'nullable', 'array', 'max:10'],
            'learning_style_preferences.*' => ['string', Rule::in(self::LEARNING_STYLE_OPTIONS), 'distinct'],
            'support_needs' => [...$s, 'nullable', 'array:attention_support,dyslexia_friendly_mode,larger_text,reduced_clutter_ui,extra_processing_time,other_notes'],
            'support_needs.attention_support' => ['sometimes', 'boolean'],
            'support_needs.dyslexia_friendly_mode' => ['sometimes', 'boolean'],
            'support_needs.larger_text' => ['sometimes', 'boolean'],
            'support_needs.reduced_clutter_ui' => ['sometimes', 'boolean'],
            'support_needs.extra_processing_time' => ['sometimes', 'boolean'],
            'support_needs.other_notes' => ['sometimes', 'nullable', 'string', 'max:300'],
            'confidence_by_subject' => [...$s, 'nullable', 'array', 'max:30'],
            'confidence_by_subject.*.subject' => ['required_with:confidence_by_subject', 'string', 'max:80'],
            'confidence_by_subject.*.confidence_level' => ['required_with:confidence_by_subject', 'integer', 'between:1,5'],
        ];
    }
}
