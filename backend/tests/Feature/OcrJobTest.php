<?php

namespace Tests\Feature;

use App\Jobs\ProcessDocumentOcr;
use App\Models\Concept;
use App\Models\Document;
use App\Services\Concepts\ConceptExtractorInterface;
use App\Services\Generation\GameGeneratorInterface;
use App\Services\Generation\LearningPackGeneratorInterface;
use App\Services\Generation\StubGameGenerator;
use App\Services\Generation\StubLearningPackGenerator;
use App\Services\Ocr\OcrClientInterface;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class OcrJobTest extends TestCase
{
    public function test_ocr_job_updates_document_with_extracted_text(): void
    {
        Storage::fake('s3');
        Storage::disk('s3')->put('children/test/documents/demo.pdf', 'demo');

        $document = Document::factory()->create([
            'storage_disk' => 's3',
            'storage_path' => 'children/test/documents/demo.pdf',
            'status' => 'queued',
        ]);

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
                    ['key' => 'fractions.addition', 'label' => 'Adding fractions', 'difficulty' => 0.7],
                ];
            }
        });

        $this->app->bind(LearningPackGeneratorInterface::class, StubLearningPackGenerator::class);
        $this->app->bind(GameGeneratorInterface::class, StubGameGenerator::class);

        (new ProcessDocumentOcr((string) $document->_id))->handle($this->app->make(OcrClientInterface::class));

        $document->refresh();
        $this->assertSame('processed', $document->status);
        $this->assertSame('Extracted OCR content', $document->extracted_text);
        $this->assertSame(1, Concept::count());
    }
}
