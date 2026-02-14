<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Jobs\QuickScanDocumentMetadata;
use App\Jobs\GenerateLearningPackFromDocument;
use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\GuestSession;
use App\Support\Documents\FacetCanonicalizer;
use App\Support\Documents\PipelineTelemetry;
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
            'topic' => ['nullable', 'string', 'max:120'],
            'title' => ['nullable', 'string', 'max:120'],
            'language' => ['nullable', 'string', 'max:32'],
            'grade_level' => ['nullable', 'string', 'max:64'],
            'document_type' => ['nullable', 'string', 'max:64'],
            'source' => ['nullable', 'string', 'max:64'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string', 'max:64'],
            'collections' => ['nullable', 'array'],
            'collections.*' => ['string', 'max:64'],
            'learning_goal' => ['nullable', 'string', 'max:160'],
            'context_text' => ['nullable', 'string', 'max:500'],
            'requested_game_types' => ['nullable', 'array'],
            'requested_game_types.*' => [
                'string',
                'in:flashcards,quiz,matching,true_false,fill_blank,ordering,multiple_select,short_answer',
            ],
            'guest_session_id' => ['nullable', 'string', 'max:60'],
        ]);

        if (blank($data['subject'] ?? null) &&
            blank($data['topic'] ?? null) &&
            blank($data['learning_goal'] ?? null)) {
            throw ValidationException::withMessages([
                'subject' => ['Provide a subject, topic, or learning goal to guide quiz generation.'],
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

        $topicFacet = FacetCanonicalizer::canonicalizeTopic($data['topic'] ?? $data['subject'] ?? null);
        $subjectCandidate = FacetCanonicalizer::canonicalizeSubject($data['subject'] ?? null)
            ?? FacetCanonicalizer::canonicalizeSubject($topicFacet);
        $subjectFacet = FacetCanonicalizer::isCoreSubject($subjectCandidate) ? $subjectCandidate : 'General';
        $languageFacet = FacetCanonicalizer::canonicalizeLanguage($data['language'] ?? null);
        if ($languageFacet === null && $subjectFacet === 'Language') {
            $languageFacet = FacetCanonicalizer::canonicalizeLanguage($topicFacet);
        }

        $guestOwnership = null;
        if (filled($data['guest_session_id'] ?? null)) {
            $guestSession = GuestSession::where('session_id', (string) $data['guest_session_id'])->first();
            if (! $guestSession ||
                (string) ($guestSession->guest_user_id ?? '') !== (string) Auth::guard('api')->id() ||
                (string) ($guestSession->guest_child_id ?? '') !== (string) $child->_id) {
                throw ValidationException::withMessages([
                    'guest_session_id' => ['Invalid guest session context.'],
                ]);
            }
            $guestOwnership = (string) $guestSession->session_id;
        }

        $document = Document::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'owner_type' => $guestOwnership ? 'guest' : 'child',
            'owner_child_id' => (string) $child->_id,
            'owner_guest_session_id' => $guestOwnership,
            'status' => 'queued',
            'original_filename' => $originalFilename ?? 'document',
            'storage_disk' => config('filesystems.default', 's3'),
            'storage_path' => $paths[0] ?? null,
            'storage_paths' => $paths,
            'mime_type' => $mimeTypes[0] ?? null,
            'mime_types' => $mimeTypes,
            'size_bytes' => $totalBytes,
            'subject' => $subjectFacet,
            'topic' => $topicFacet ?? $subjectFacet,
            'title' => $data['title'] ?? null,
            'language' => $languageFacet,
            'grade_level' => FacetCanonicalizer::canonicalizeGradeLevel($data['grade_level'] ?? null),
            'document_type' => $data['document_type'] ?? null,
            'source' => $data['source'] ?? null,
            'tags' => FacetCanonicalizer::canonicalizeList($data['tags'] ?? []),
            'collections' => FacetCanonicalizer::canonicalizeList($data['collections'] ?? []),
            'ai_confidence' => null,
            'user_override' => false,
            'learning_goal' => $data['learning_goal'] ?? null,
            'context_text' => $data['context_text'] ?? null,
            'requested_game_types' => $data['requested_game_types'] ?? null,
            'scan_status' => 'queued',
            'scan_topic_suggestion' => null,
            'scan_language_suggestion' => null,
            'scan_confidence' => null,
            'scan_alternatives' => [],
            'scan_model' => null,
            'scan_completed_at' => null,
            'validation_status' => 'pending',
            'validated_topic' => null,
            'validated_language' => null,
            'validated_at' => null,
            'pipeline_stage' => null,
            'stage_started_at' => null,
            'progress_hint' => 0,
            'first_playable_at' => null,
            'first_playable_game_type' => null,
            'ready_game_types' => [],
            'stage_timings' => [],
            'stage_history' => [],
        ]);
        PipelineTelemetry::transition($document, 'quick_scan_queued', 10, 'queued');
        $document->save();

        QuickScanDocumentMetadata::dispatch((string) $document->_id);

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

    public function regenerate(Request $request, string $childId, string $documentId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $data = $request->validate([
            'requested_game_types' => ['nullable', 'array'],
            'requested_game_types.*' => [
                'string',
                'in:flashcards,quiz,matching,true_false,fill_blank,ordering,multiple_select,short_answer',
            ],
        ]);

        $document = Document::where('_id', $documentId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        PipelineTelemetry::transition($document, 'queued', 5, 'queued');
        $document->ocr_error = null;
        $document->first_playable_at = null;
        $document->first_playable_game_type = null;
        $document->ready_game_types = [];
        if (array_key_exists('requested_game_types', $data)) {
            $requested = array_values(array_unique($data['requested_game_types'] ?? []));
            $document->requested_game_types = $requested === [] ? null : $requested;
        } else {
            // Generic "redo document" should regenerate full/default game set.
            $document->requested_game_types = null;
        }
        $document->save();

        GenerateLearningPackFromDocument::dispatch((string) $document->_id);

        return response()->json([
            'data' => $document,
        ], 202);
    }

}
