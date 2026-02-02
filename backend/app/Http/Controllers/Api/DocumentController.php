<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessDocumentOcr;
use App\Models\ChildProfile;
use App\Models\Document;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class DocumentController extends Controller
{
    public function index(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $documents = Document::where('child_profile_id', (string) $child->_id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $documents,
        ]);
    }

    public function store(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $data = $request->validate([
            'file' => ['required', 'file', 'max:10240', 'mimes:pdf,jpg,jpeg,png'],
            'subject' => ['nullable', 'string', 'max:120'],
            'language' => ['nullable', 'string', 'max:32'],
            'grade_level' => ['nullable', 'string', 'max:64'],
            'learning_goal' => ['nullable', 'string', 'max:160'],
            'context_text' => ['nullable', 'string', 'max:500'],
        ]);

        $file = $data['file'];
        $extension = $file->getClientOriginalExtension() ?: $file->guessExtension();
        $path = sprintf(
            'children/%s/documents/%s.%s',
            (string) $child->_id,
            (string) Str::uuid(),
            $extension ?: 'bin'
        );

        $disk = Storage::disk(config('filesystems.default', 's3'));
        $disk->put($path, $file->getContent(), [
            'visibility' => 'private',
            'mimetype' => $file->getClientMimeType(),
        ]);

        $document = Document::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'original_filename' => $file->getClientOriginalName(),
            'storage_disk' => config('filesystems.default', 's3'),
            'storage_path' => $path,
            'mime_type' => $file->getClientMimeType(),
            'size_bytes' => $file->getSize(),
            'subject' => $data['subject'] ?? null,
            'language' => $data['language'] ?? null,
            'grade_level' => $data['grade_level'] ?? null,
            'learning_goal' => $data['learning_goal'] ?? null,
            'context_text' => $data['context_text'] ?? null,
        ]);

        ProcessDocumentOcr::dispatch((string) $document->_id);

        return response()->json([
            'data' => $document,
        ], 201);
    }

    public function show(string $childId, string $documentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $document = Document::where('_id', $documentId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        return response()->json([
            'data' => $document,
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
