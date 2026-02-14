<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\LearningPack;
use App\Models\MasteryProfile;
use App\Services\Schemas\JsonSchemaValidator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LearningPackController extends Controller
{
    use FindsOwnedChild;
    public function index(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $query = LearningPack::where('child_profile_id', (string) $child->_id);

        if ($request->filled('document_id')) {
            $query->where('document_id', $request->string('document_id')->toString());
        }

        $packs = $query->orderBy('created_at', 'desc')->get();

        $childId = (string) $child->_id;
        $masteryByKey = MasteryProfile::where('child_profile_id', $childId)
            ->get(['concept_key', 'mastery_level'])
            ->keyBy('concept_key');

        $enriched = $packs->map(function ($pack) use ($masteryByKey) {
            $concepts = $pack->content['concepts'] ?? [];
            $keys = array_map(fn ($c) => $c['key'] ?? $c['concept_key'] ?? '', $concepts);
            $keys = array_filter($keys);
            $total = count($keys);

            $sumMastery = 0.0;
            $mastered = 0;
            foreach ($keys as $key) {
                $profile = $masteryByKey->get($key);
                if ($profile) {
                    $sumMastery += $profile->mastery_level;
                    if ($profile->mastery_level >= 0.8) {
                        $mastered++;
                    }
                }
            }

            $data = $pack->toArray();
            $data['mastery_percentage'] = $total > 0 ? round($sumMastery / $total * 100) : 0;
            $data['concepts_mastered'] = $mastered;
            $data['concepts_total'] = $total;

            return $data;
        });

        return response()->json([
            'data' => $enriched->values(),
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

        $schemaPath = resource_path('schemas/learning_pack.json');
        $validator->validate($data['content'], $schemaPath);

        $pack = LearningPack::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'owner_type' => (string) ($document->owner_type ?: 'child'),
            'owner_child_id' => (string) $child->_id,
            'owner_guest_session_id' => $document->owner_guest_session_id,
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

}
