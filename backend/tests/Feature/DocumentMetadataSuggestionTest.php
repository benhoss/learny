<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class DocumentMetadataSuggestionTest extends TestCase
{
    public function test_metadata_suggestion_endpoint_returns_prefill_payload(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/documents/metadata-suggestions', [
                'filename' => 'fractions-homework.jpg',
                'context_text' => 'Need to practice math fractions and equations',
            ]);

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'subject',
                    'language',
                    'learning_goal',
                    'confidence',
                    'alternatives',
                ],
            ])
            ->assertJsonPath('data.subject', 'Math');
    }
}
