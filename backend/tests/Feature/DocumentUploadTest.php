<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\User;
use App\Jobs\GenerateLearningPackFromDocument;
use App\Jobs\ProcessDocumentOcr;
use App\Jobs\QuickScanDocumentMetadata;
use App\Services\Concepts\ConceptExtractorInterface;
use App\Services\Generation\GameGeneratorInterface;
use App\Services\Generation\LearningPackGeneratorInterface;
use App\Services\Generation\StubGameGenerator;
use App\Services\Generation\StubLearningPackGenerator;
use App\Services\Documents\QuickScanService;
use App\Services\Ocr\OcrClientInterface;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DocumentUploadTest extends TestCase
{
    public function test_parent_can_upload_document_and_prepare_scan_validation_gate(): void
    {
        Storage::fake('s3');

        $user = User::create([
            'name' => 'Parent',
            'email' => 'parent5@example.com',
            'password' => 'secret123',
        ]);

        $child = ChildProfile::create([
            'user_id' => (string) $user->_id,
            'name' => 'Sam',
            'grade_level' => '5th',
            'birth_year' => 2014,
        ]);

        $token = Auth::guard('api')->login($user);

        $this->app->bind(OcrClientInterface::class, fn () => new class implements OcrClientInterface {
            public function extractText(string $disk, string $path, ?string $mimeType = null): string
            {
                return 'Extracted OCR content';
            }
        });

        $this->app->bind(ConceptExtractorInterface::class, fn () => new class implements ConceptExtractorInterface {
            public function extract(string $text, ?string $language = null): array
            {
                return [
                    ['key' => 'division.basics', 'label' => 'Division basics', 'difficulty' => 0.4],
                ];
            }
        });

        $this->app->bind(LearningPackGeneratorInterface::class, StubLearningPackGenerator::class);
        $this->app->bind(GameGeneratorInterface::class, StubGameGenerator::class);

        $file = UploadedFile::fake()->create('worksheet.pdf', 120, 'application/pdf');

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->withHeader('Accept', 'application/json')
            ->post('/api/v1/children/'.$child->_id.'/documents', [
                'file' => $file,
                'subject' => 'Division basics',
            ]);

        $response->assertStatus(201);
        $documentId = $this->extractId($response->json('data'));

        $document = Document::find($documentId);
        $this->assertNotNull($document);
        $this->assertSame('queued', $document->status);
        $this->assertSame('awaiting_validation', $document->pipeline_stage);
        $this->assertSame('ready', $document->scan_status);
        $this->assertSame('pending', $document->validation_status);
        $this->assertNotNull($document->scan_topic_suggestion);
        $this->assertNotNull($document->scan_language_suggestion);
        $this->assertNull($document->extracted_text);

        Storage::disk('s3')->assertExists($document->storage_path);
    }

    public function test_confirm_scan_dispatches_ocr_and_persists_validated_context(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'scan_status' => 'ready',
            'validation_status' => 'pending',
            'pipeline_stage' => 'awaiting_validation',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/confirm-scan', [
                'topic' => 'Math',
                'language' => 'French',
            ]);

        $response->assertStatus(202);

        $document->refresh();
        $this->assertSame('confirmed', $document->validation_status);
        $this->assertSame('Math', $document->validated_topic);
        $this->assertSame('French', $document->validated_language);
        $this->assertSame('Math', $document->subject);
        $this->assertSame('French', $document->language);

        Queue::assertPushed(ProcessDocumentOcr::class);
    }

    public function test_upload_normalizes_subject_topic_language_and_lists_to_canonical_facets(): void
    {
        Storage::fake('s3');

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $file = UploadedFile::fake()->create('worksheet.pdf', 120, 'application/pdf');

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->withHeader('Accept', 'application/json')
            ->post('/api/v1/children/'.$child->_id.'/documents', [
                'file' => $file,
                'subject' => 'sciences',
                'topic' => '  SCIENCE  ',
                'language' => 'french',
                'tags' => [' verbs ', 'Verbs', 'grammar'],
                'collections' => [' exam week ', 'Exam Week'],
            ]);

        $response->assertStatus(201);
        $documentId = $this->extractId($response->json('data'));
        $document = Document::find($documentId);
        $this->assertNotNull($document);
        $this->assertSame('Science', $document->subject);
        $this->assertSame('Science', $document->topic);
        $this->assertSame('French', $document->language);
        $this->assertSame(['Verbs', 'Grammar'], $document->tags);
        $this->assertSame(['Exam Week'], $document->collections);
    }

    public function test_confirm_scan_normalizes_topic_and_language_and_sets_controlled_subject(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'subject' => null,
            'status' => 'queued',
            'scan_status' => 'ready',
            'validation_status' => 'pending',
            'pipeline_stage' => 'awaiting_validation',
            'scan_topic_suggestion' => 'Science',
            'scan_language_suggestion' => 'French',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/confirm-scan', [
                'topic' => 'sciences',
                'language' => 'french',
            ]);

        $response->assertStatus(202);

        $document->refresh();
        $this->assertSame('Science', $document->subject);
        $this->assertSame('Science', $document->topic);
        $this->assertSame('French', $document->language);
        $this->assertSame('Science', $document->validated_topic);
        $this->assertSame('French', $document->validated_language);
        $this->assertFalse((bool) $document->user_override);
        Queue::assertPushed(ProcessDocumentOcr::class);
    }

    public function test_confirm_scan_is_idempotent_after_first_confirmation(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'scan_status' => 'ready',
            'validation_status' => 'pending',
            'pipeline_stage' => 'awaiting_validation',
        ]);

        $first = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/confirm-scan', [
                'topic' => 'Math',
                'language' => 'French',
            ]);

        $first->assertStatus(202);
        Queue::assertPushed(ProcessDocumentOcr::class, 1);

        $second = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/confirm-scan', [
                'topic' => 'Math',
                'language' => 'French',
            ]);

        $second->assertStatus(200);
        Queue::assertPushed(ProcessDocumentOcr::class, 1);
    }

    public function test_confirm_scan_rejects_documents_outside_validation_stage(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'processing',
            'scan_status' => 'ready',
            'validation_status' => 'pending',
            'pipeline_stage' => 'learning_pack_generation',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/confirm-scan', [
                'topic' => 'Science',
                'language' => 'English',
            ]);

        $response->assertStatus(409);
        $response->assertJsonPath(
            'message',
            'Document cannot be confirmed in its current state.'
        );

        Queue::assertNotPushed(ProcessDocumentOcr::class);
    }

    public function test_quick_scan_job_does_not_override_confirmed_document_state(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'scan_status' => 'ready',
            'validation_status' => 'confirmed',
            'validated_topic' => 'History',
            'validated_language' => 'English',
            'pipeline_stage' => 'queued',
        ]);

        $scanService = $this->mock(QuickScanService::class);
        $scanService->shouldNotReceive('scan');

        (new QuickScanDocumentMetadata((string) $document->_id))->handle($scanService);

        $document->refresh();
        $this->assertSame('confirmed', $document->validation_status);
        $this->assertSame('History', $document->validated_topic);
        $this->assertSame('English', $document->validated_language);
        $this->assertSame('queued', $document->pipeline_stage);
    }

    public function test_confirm_scan_returns_conflict_when_confirmation_lock_is_held(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'scan_status' => 'ready',
            'validation_status' => 'pending',
            'pipeline_stage' => 'awaiting_validation',
        ]);

        $lock = Cache::lock('documents:confirm-scan:'.(string) $document->_id, 5);
        $this->assertTrue($lock->get());

        try {
            $response = $this->withHeader('Authorization', 'Bearer '.$token)
                ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/confirm-scan', [
                    'topic' => 'Math',
                    'language' => 'French',
                ]);

            $response->assertStatus(409);
            Queue::assertNotPushed(ProcessDocumentOcr::class);
        } finally {
            $lock->release();
        }
    }

    public function test_rescan_resets_scan_fields_and_dispatches_quick_scan(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'scan_status' => 'ready',
            'scan_topic_suggestion' => 'Plants',
            'scan_language_suggestion' => 'Dutch',
            'scan_confidence' => 0.93,
            'scan_alternatives' => ['Biology'],
            'scan_model' => 'fast-v1',
            'validation_status' => 'pending',
            'pipeline_stage' => 'awaiting_validation',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/rescan');

        $response->assertStatus(202);

        $document->refresh();
        $this->assertSame('queued', $document->scan_status);
        $this->assertSame('pending', $document->validation_status);
        $this->assertNull($document->scan_topic_suggestion);
        $this->assertNull($document->scan_language_suggestion);
        $this->assertNull($document->scan_confidence);
        $this->assertSame([], $document->scan_alternatives);
        $this->assertNull($document->scan_model);
        $this->assertSame('quick_scan_queued', $document->pipeline_stage);

        Queue::assertPushed(QuickScanDocumentMetadata::class);
    }

    public function test_rescan_returns_conflict_when_rescan_lock_is_held(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'scan_status' => 'ready',
            'validation_status' => 'pending',
            'pipeline_stage' => 'awaiting_validation',
        ]);

        $lock = Cache::lock('documents:rescan:'.(string) $document->_id, 5);
        $this->assertTrue($lock->get());

        try {
            $response = $this->withHeader('Authorization', 'Bearer '.$token)
                ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/rescan');

            $response->assertStatus(409);
            $response->assertJsonPath(
                'message',
                'Document rescan already in progress. Please retry.'
            );
            Queue::assertNotPushed(QuickScanDocumentMetadata::class);
        } finally {
            $lock->release();
        }
    }

    public function test_rescan_rejects_confirmed_document_and_does_not_dispatch_job(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'queued',
            'scan_status' => 'ready',
            'validation_status' => 'confirmed',
            'pipeline_stage' => 'queued',
            'scan_topic_suggestion' => 'Math',
            'scan_language_suggestion' => 'French',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/rescan');

        $response->assertStatus(409);
        $response->assertJsonPath('message', 'Document cannot be rescanned in its current state.');

        $document->refresh();
        $this->assertSame('confirmed', $document->validation_status);
        $this->assertSame('queued', $document->pipeline_stage);
        $this->assertSame('ready', $document->scan_status);
        $this->assertSame('Math', $document->scan_topic_suggestion);
        $this->assertSame('French', $document->scan_language_suggestion);

        Queue::assertNotPushed(QuickScanDocumentMetadata::class);
    }

    public function test_rescan_rejects_document_already_in_deep_processing_stage(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'processing',
            'scan_status' => 'ready',
            'validation_status' => 'pending',
            'pipeline_stage' => 'learning_pack_generation',
            'scan_topic_suggestion' => 'Science',
            'scan_language_suggestion' => 'English',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/rescan');

        $response->assertStatus(409);
        $response->assertJsonPath('message', 'Document cannot be rescanned in its current state.');

        $document->refresh();
        $this->assertSame('learning_pack_generation', $document->pipeline_stage);
        $this->assertSame('pending', $document->validation_status);
        $this->assertSame('ready', $document->scan_status);
        $this->assertSame('Science', $document->scan_topic_suggestion);
        $this->assertSame('English', $document->scan_language_suggestion);

        Queue::assertNotPushed(QuickScanDocumentMetadata::class);
    }

    public function test_regenerate_without_requested_types_clears_previous_filter(): void
    {
        Queue::fake();

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'ready',
            'requested_game_types' => ['quiz'],
            'pipeline_stage' => 'ready',
            'progress_hint' => 100,
        ]);

        $token = Auth::guard('api')->login($user);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/'.$document->_id.'/regenerate', []);

        $response->assertStatus(202);

        $document->refresh();
        $this->assertNull($document->requested_game_types);
        $this->assertSame('queued', $document->status);
        $this->assertSame('queued', $document->pipeline_stage);

        Queue::assertPushed(GenerateLearningPackFromDocument::class);
    }
}
