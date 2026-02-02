<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\LearningPack;
use App\Services\Schemas\JsonSchemaValidator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LearningPackController extends Controller
{
    public function index(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $query = LearningPack::where('child_profile_id', (string) $child->_id);

        if ($request->filled('document_id')) {
            $query->where('document_id', $request->string('document_id')->toString());
        }

        $packs = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'data' => $packs,
        ]);
    }

    public function store(Request $request, string $childId, JsonSchemaValidator $validator): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $data = $request->validate([
            'document_id' => ['required', 'string'],
            'title' => ['required', 'string', 'max:150'],
            'summary' => ['nullable', 'string', 'max:500'],
            'content' => ['required', 'array'],
        ]);

        $document = Document::where('_id', $data['document_id'])
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        $schemaPath = storage_path('app/schemas/learning_pack.json');
        $validator->validate($data['content'], $schemaPath);

        $pack = LearningPack::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'document_id' => (string) $document->_id,
            'title' => $data['title'],
            'summary' => $data['summary'] ?? null,
            'status' => 'ready',
            'schema_version' => 'v1',
            'content' => $data['content'],
        ]);

        return response()->json([
            'data' => $pack,
        ], 201);
    }

    public function show(string $childId, string $packId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $pack = LearningPack::where('_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        return response()->json([
            'data' => $pack,
        ]);
    }

    protected function findOwnedChild(string $childId): ChildProfile
    {
        $userId = (string) Auth::guard('api')->id();

        return ChildProfile::where('_id', $childId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }
}
