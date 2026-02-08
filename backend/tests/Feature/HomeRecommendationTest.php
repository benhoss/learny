<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
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

    public function test_home_recommendations_include_streak_rescue_action_when_streak_at_risk(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
            'streak_days' => 4,
            'last_activity_date' => now()->subDays(2),
        ]);
        $token = Auth::guard('api')->login($user);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/home-recommendations');

        $response->assertOk();
        $actions = collect($response->json('data'))->pluck('action')->all();
        $this->assertContains('start_streak_rescue', $actions);
    }

    public function test_home_recommendations_respect_memory_personalization_toggle(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
            'memory_personalization_enabled' => false,
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

        Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'ready',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/home-recommendations');

        $response->assertOk();
        $types = collect($response->json('data'))->pluck('type')->all();
        $this->assertNotContains('review_due', $types);
        $this->assertNotContains('weak_area', $types);
        $this->assertContains('generic_practice', $types);
    }

    public function test_home_recommendation_event_tracking_creates_memory_event(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/home-recommendations/events', [
                'recommendation_id' => 'due:fractions.addition',
                'recommendation_type' => 'review_due',
                'action' => 'start_revision',
                'event' => 'tap',
            ]);

        $response->assertOk()
            ->assertJsonPath('data.recorded', true);

        $responseTwo = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/home-recommendations/events', [
                'recommendation_id' => 'due:fractions.addition',
                'recommendation_type' => 'review_due',
                'action' => 'start_revision',
                'event' => 'tap',
            ]);

        $responseTwo->assertOk()
            ->assertJsonPath('data.recorded', true);

        $this->assertSame(
            2,
            LearningMemoryEvent::where('child_profile_id', (string) $child->_id)
                ->where('event_type', 'recommendation')
                ->count()
        );
    }
}
