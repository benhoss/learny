<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ChildProfileController extends Controller
{
    public function index(): JsonResponse
    {
        $userId = (string) Auth::guard('api')->id();

        return response()->json([
            'data' => ChildProfile::where('user_id', $userId)->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'grade_level' => ['nullable', 'string', 'max:50'],
            'birth_year' => ['nullable', 'integer', 'between:2000,2100'],
            'notes' => ['nullable', 'string', 'max:500'],
        ]);

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

        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:100'],
            'grade_level' => ['sometimes', 'nullable', 'string', 'max:50'],
            'birth_year' => ['sometimes', 'nullable', 'integer', 'between:2000,2100'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:500'],
        ]);

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
}
