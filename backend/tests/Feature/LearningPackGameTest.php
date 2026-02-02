<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class LearningPackGameTest extends TestCase
{
    public function test_create_learning_pack_and_game_with_valid_schema(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
        ]);

        $token = Auth::guard('api')->login($user);

        $packPayload = [
            'document_id' => (string) $document->_id,
            'title' => 'Fractions Pack',
            'summary' => 'Practice adding fractions',
            'content' => [
                'objective' => 'Understand adding fractions',
                'concepts' => [
                    ['key' => 'fractions.addition', 'label' => 'Adding fractions', 'difficulty' => 0.6],
                ],
                'items' => [
                    [
                        'type' => 'flashcards',
                        'content' => [
                            'cards' => [
                                ['front' => '1/2 + 1/4', 'back' => '3/4'],
                            ],
                        ],
                    ],
                ],
            ],
        ];

        $packResponse = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs', $packPayload);

        $packResponse->assertStatus(201);
        $packId = $this->extractId($packResponse->json('data'));

        $gamePayload = [
            'type' => 'quiz',
            'payload' => [
                'questions' => [
                    [
                        'prompt' => '2 + 2 = ?',
                        'choices' => ['3', '4'],
                        'answer_index' => 1,
                    ],
                ],
            ],
        ];

        $gameResponse = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$packId.'/games', $gamePayload);

        $gameResponse->assertStatus(201)
            ->assertJsonPath('data.type', 'quiz');
    }

    public function test_learning_pack_schema_validation_fails(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
        ]);

        $token = Auth::guard('api')->login($user);

        $invalidPayload = [
            'document_id' => (string) $document->_id,
            'title' => 'Invalid Pack',
            'content' => [
                'summary' => 'Missing objective and concepts',
            ],
        ];

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs', $invalidPayload);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'Invalid payload schema.');
    }

    public function test_game_schema_validation_fails(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
        ]);
        $pack = [
            'document_id' => (string) $document->_id,
            'title' => 'Pack',
            'content' => [
                'objective' => 'Learn basics',
                'concepts' => [
                    ['key' => 'basic', 'label' => 'Basic'],
                ],
                'items' => [
                    [
                        'type' => 'flashcards',
                        'content' => [
                            'cards' => [
                                ['front' => '1+1', 'back' => '2'],
                            ],
                        ],
                    ],
                ],
            ],
        ];

        $token = Auth::guard('api')->login($user);

        $packResponse = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs', $pack);

        $packId = $this->extractId($packResponse->json('data'));

        $invalidGame = [
            'type' => 'quiz',
            'payload' => [
                'questions' => [
                    [
                        'prompt' => '2 + 2 = ?',
                        'choices' => ['3', '4'],
                    ],
                ],
            ],
        ];

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$packId.'/games', $invalidGame);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'Invalid payload schema.');
    }
}
