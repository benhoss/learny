<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\LearningMemoryEvent;
use App\Models\MasteryProfile;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class HomeRecommendationTest extends TestCase
{
    public function test_home_recommendations_include_due_and_weak_signals(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        MasteryProfile::create([
            'child_profile_id' => (string) $child->_id,
            'concept_key' => 'fractions.addition',
            'concept_label' => 'Adding fractions',
            'mastery_level' => 0.5,
            'total_attempts' => 6,
            'correct_attempts' => 3,
            'next_review_at' => now()->subHour(),
        ]);

        LearningMemoryEvent::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'concept_key' => 'fractions.addition',
            'event_type' => 'play',
            'source_type' => 'game_result',
            'source_id' => 'gr-1',
            'occurred_at' => now()->subDay(),
            'confidence' => 0.2,
            'metadata' => ['correct' => false],
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/home-recommendations');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    [
                        'id',
                        'type',
                        'title',
                        'subtitle',
                        'priority_score',
                        'action',
                        'explainability',
                    ],
                ],
            ]);

        $types = collect($response->json('data'))->pluck('type')->all();
        $this->assertContains('review_due', $types);
    }
}
