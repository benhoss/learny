<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Jobs\ProcessDocumentOcr;
use App\Jobs\GenerateLearningPackFromDocument;
use App\Models\ChildProfile;
use App\Models\Document;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class DocumentController extends Controller
{
    use FindsOwnedChild;
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
            'file' => ['required_without:files', 'file', 'max:10240', 'mimes:pdf,jpg,jpeg,png'],
            'files' => ['required_without:file', 'array', 'min:1'],
            'files.*' => ['file', 'max:10240', 'mimes:jpg,jpeg,png'],
            'subject' => ['nullable', 'string', 'max:120'],
            'language' => ['nullable', 'string', 'max:32'],
            'grade_level' => ['nullable', 'string', 'max:64'],
            'learning_goal' => ['nullable', 'string', 'max:160'],
            'context_text' => ['nullable', 'string', 'max:500'],
            'requested_game_types' => ['nullable', 'array'],
            'requested_game_types.*' => [
                'string',
                'in:flashcards,quiz,matching,true_false,fill_blank,ordering,multiple_select,short_answer',
            ],
        ]);

        if (blank($data['subject'] ?? null) && blank($data['learning_goal'] ?? null)) {
            throw ValidationException::withMessages([
                'subject' => ['Provide a subject or learning goal to guide quiz generation.'],
            ]);
        }

        $disk = Storage::disk(config('filesystems.default', 's3'));
        $paths = [];
        $mimeTypes = [];
        $totalBytes = 0;
        $originalFilename = null;

        $files = [];
        if (isset($data['files'])) {
            $files = $data['files'];
        } elseif (isset($data['file'])) {
            $files = [$data['file']];
        }

        foreach ($files as $index => $file) {
            $extension = $file->getClientOriginalExtension() ?: $file->guessExtension();
            $path = sprintf(
                'children/%s/documents/%s-%s.%s',
                (string) $child->_id,
                (string) Str::uuid(),
                $index + 1,
                $extension ?: 'bin'
            );
            $disk->put($path, $file->getContent(), [
                'visibility' => 'private',
                'mimetype' => $file->getClientMimeType(),
            ]);
            $paths[] = $path;
            $mimeTypes[] = $file->getClientMimeType();
            $totalBytes += $file->getSize();
            if ($originalFilename === null) {
                $originalFilename = $file->getClientOriginalName();
            }
        }

        $document = Document::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'original_filename' => $originalFilename ?? 'document',
            'storage_disk' => config('filesystems.default', 's3'),
            'storage_path' => $paths[0] ?? null,
            'storage_paths' => $paths,
            'mime_type' => $mimeTypes[0] ?? null,
            'mime_types' => $mimeTypes,
            'size_bytes' => $totalBytes,
            'subject' => $data['subject'] ?? null,
            'language' => $data['language'] ?? null,
            'grade_level' => $data['grade_level'] ?? null,
            'learning_goal' => $data['learning_goal'] ?? null,
            'context_text' => $data['context_text'] ?? null,
            'requested_game_types' => $data['requested_game_types'] ?? null,
            'pipeline_stage' => 'queued',
            'stage_started_at' => now(),
            'progress_hint' => 5,
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

    public function regenerate(string $childId, string $documentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $document = Document::where('_id', $documentId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        $document->status = 'queued';
        $document->pipeline_stage = 'queued';
        $document->stage_started_at = now();
        $document->stage_completed_at = null;
        $document->progress_hint = 5;
        $document->ocr_error = null;
        $document->save();

        GenerateLearningPackFromDocument::dispatch((string) $document->_id);

        return response()->json([
            'data' => $document,
        ], 202);
    }

}
