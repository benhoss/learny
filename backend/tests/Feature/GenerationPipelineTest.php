<?php

namespace Tests\Feature;

use App\Jobs\GenerateLearningPackFromDocument;
use App\Models\AiGenerationArtifact;
use App\Models\AiGenerationRun;
use App\Models\AiGuardrailResult;
use App\Models\Concept;
use App\Models\Document;
use App\Models\Game;
use App\Models\LearningPack;
use App\Models\User;
use App\Models\ChildProfile;
use App\Services\Generation\GameGeneratorInterface;
use App\Services\Generation\LearningPackGeneratorInterface;
use App\Services\Generation\StubGameGenerator;
use App\Services\Generation\StubLearningPackGenerator;
use Illuminate\Support\Facades\Crypt;
use RuntimeException;
use Tests\TestCase;

class GenerationPipelineTest extends TestCase
{
    public function test_learning_pack_and_games_are_generated(): void
    {
        $this->app->bind(LearningPackGeneratorInterface::class, StubLearningPackGenerator::class);
        $this->app->bind(GameGeneratorInterface::class, StubGameGenerator::class);

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'extracted_text' => 'Sample math content about fractions.',
        ]);

        Concept::factory()->create([
            'child_profile_id' => (string) $child->_id,
            'document_id' => (string) $document->_id,
            'concept_key' => 'fractions.addition',
            'concept_label' => 'Adding fractions',
            'difficulty' => 0.6,
        ]);

        (new GenerateLearningPackFromDocument((string) $document->_id))->handle(
            $this->app->make(LearningPackGeneratorInterface::class),
            $this->app->make(\App\Services\Schemas\JsonSchemaValidator::class),
            $this->app->make(\App\Services\Safety\GenerationSafetyGuard::class)
        );

        $this->assertSame(1, LearningPack::count());
        $this->assertSame(8, Game::count());

        $document->refresh();
        $this->assertNotNull($document->first_playable_at);
        $this->assertNotNull($document->first_playable_game_type);
        $this->assertNotEmpty($document->ready_game_types ?? []);
        $this->assertArrayHasKey('game_generation', $document->stage_timings ?? []);

        $this->assertSame(9, AiGenerationRun::count());
        $this->assertSame(18, AiGuardrailResult::count());
        $this->assertSame(9, AiGenerationArtifact::count());

        $artifact = AiGenerationArtifact::first();
        $this->assertNotNull($artifact);
        $decryptedArtifact = Crypt::decryptString((string) $artifact->content_encrypted);
        $this->assertStringNotContainsString('Sample math content about fractions.', (string) $artifact->content_encrypted);
        $this->assertNotSame((string) $artifact->content_encrypted, $decryptedArtifact);
        $this->assertSame(hash('sha256', $decryptedArtifact), (string) $artifact->content_hash);

        $this->assertSame(0, AiGenerationRun::where('final_status', '!=', 'served')->count());
    }

    public function test_learning_pack_generation_is_blocked_when_guardrail_fails(): void
    {
        $this->app->bind(LearningPackGeneratorInterface::class, fn () => new class implements LearningPackGeneratorInterface {
            public function generate(Document $document, array $concepts): array
            {
                return [
                    'objective' => 'Understand fractions',
                    'summary' => 'This includes unsafe guidance: how to cheat on tests.',
                    'language' => 'en',
                    'difficulty' => 0.5,
                    'concepts' => [
                        [
                            'key' => 'fractions.addition',
                            'label' => 'Adding fractions',
                            'difficulty' => 0.5,
                        ],
                    ],
                    'items' => [
                        [
                            'type' => 'flashcards',
                            'content' => [
                                'cards' => [
                                    [
                                        'front' => '1/2 + 1/2',
                                        'back' => '1',
                                        'topic' => 'fractions.addition',
                                        'difficulty' => 0.5,
                                    ],
                                ],
                            ],
                        ],
                    ],
                ];
            }
        });

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'extracted_text' => 'Sample math content about fractions.',
        ]);

        Concept::factory()->create([
            'child_profile_id' => (string) $child->_id,
            'document_id' => (string) $document->_id,
            'concept_key' => 'fractions.addition',
            'concept_label' => 'Adding fractions',
            'difficulty' => 0.6,
        ]);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('Safety guardrail blocked learning pack generation.');

        try {
            (new GenerateLearningPackFromDocument((string) $document->_id))->handle(
                $this->app->make(LearningPackGeneratorInterface::class),
                $this->app->make(\App\Services\Schemas\JsonSchemaValidator::class),
                $this->app->make(\App\Services\Safety\GenerationSafetyGuard::class)
            );
        } finally {
            $document->refresh();

            $this->assertSame('failed', $document->status);
            $this->assertSame(0, LearningPack::count());
            $this->assertSame(1, AiGenerationRun::count());

            $run = AiGenerationRun::first();
            $this->assertSame('blocked', $run->final_status);

            $guardrail = AiGuardrailResult::where('run_id', (string) $run->_id)
                ->where('check_name', 'child_safety_terms')
                ->first();

            $this->assertNotNull($guardrail);
            $this->assertSame('fail', $guardrail->result);
            $this->assertContains('unsafe_content_detected', $guardrail->reason_codes ?? []);
        }
    }
}
