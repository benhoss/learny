<?php

namespace Tests\Feature;

use App\Jobs\GenerateLearningPackFromDocument;
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
            $this->app->make(\App\Services\Schemas\JsonSchemaValidator::class)
        );

        $this->assertSame(1, LearningPack::count());
        $this->assertSame(3, Game::count());
    }
}
