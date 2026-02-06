<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\User;
use App\Services\Concepts\ConceptExtractorInterface;
use App\Services\Generation\GameGeneratorInterface;
use App\Services\Generation\LearningPackGeneratorInterface;
use App\Services\Generation\StubGameGenerator;
use App\Services\Generation\StubLearningPackGenerator;
use App\Services\Ocr\OcrClientInterface;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DocumentUploadTest extends TestCase
{
    public function test_parent_can_upload_document_and_process_ocr(): void
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
            public function extract(string $text): array
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
        $this->assertSame('processed', $document->status);
        $this->assertSame('Extracted OCR content', $document->extracted_text);

        Storage::disk('s3')->assertExists($document->storage_path);
    }
}
