<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\GameResult;
use App\Models\LearningMemoryEvent;
use App\Models\MasteryProfile;
use App\Models\RevisionSession;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class MemoryPreferencesTest extends TestCase
{
    public function test_memory_preferences_can_be_read_and_updated(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
            'streak_days' => 9,
            'longest_streak' => 12,
            'total_xp' => 999,
            'last_activity_date' => now()->subDays(3)->toDateString(),
        ]);
        $token = Auth::guard('api')->login($user);

        $show = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/memory/preferences');

        $show->assertOk()
            ->assertJsonPath('data.memory_personalization_enabled', true)
            ->assertJsonPath('data.recommendation_why_enabled', true)
            ->assertJsonPath('data.recommendation_why_level', 'detailed');

        $update = $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/children/'.$child->_id.'/memory/preferences', [
                'memory_personalization_enabled' => false,
                'recommendation_why_enabled' => false,
                'recommendation_why_level' => 'brief',
            ]);

        $update->assertOk()
            ->assertJsonPath('data.memory_personalization_enabled', false)
            ->assertJsonPath('data.recommendation_why_enabled', false)
            ->assertJsonPath('data.recommendation_why_level', 'brief');

        $child->refresh();
        $this->assertFalse((bool) $child->memory_personalization_enabled);
        $this->assertFalse((bool) $child->recommendation_why_enabled);
        $this->assertSame('brief', (string) $child->recommendation_why_level);
    }

    public function test_clear_scope_can_delete_events_and_all_memory_related_records(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        LearningMemoryEvent::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'concept_key' => 'fractions.addition',
            'event_type' => 'review',
            'source_type' => 'revision_session',
            'source_id' => 'rev-1',
            'event_key' => 'ev-1',
            'event_order' => 1,
            'occurred_at' => now(),
            'confidence' => 0.7,
            'metadata' => [],
        ]);

        RevisionSession::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'source' => 'mixed',
            'status' => 'completed',
            'started_at' => now()->subMinutes(5),
            'completed_at' => now(),
            'total_items' => 1,
            'correct_items' => 1,
            'xp_earned' => 3,
            'subject_label' => 'Quick Revision',
            'duration_minutes' => 5,
            'items' => [],
            'results' => [],
        ]);

        GameResult::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => 'pack-1',
            'game_id' => 'game-1',
            'game_type' => 'quiz',
            'schema_version' => 'v1',
            'game_payload' => [],
            'results' => [],
            'score' => 1.0,
            'total_questions' => 1,
            'correct_answers' => 1,
            'xp_earned' => 10,
            'metadata' => [],
            'completed_at' => now(),
        ]);

        MasteryProfile::create([
            'child_profile_id' => (string) $child->_id,
            'concept_key' => 'fractions.addition',
            'concept_label' => 'Adding fractions',
            'mastery_level' => 0.4,
            'total_attempts' => 3,
            'correct_attempts' => 1,
            'next_review_at' => now()->subHour(),
        ]);

        $eventsOnly = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/memory/clear-scope', [
                'scope' => 'events',
            ]);

        $eventsOnly->assertOk()
            ->assertJsonPath('data.scope', 'events')
            ->assertJsonPath('data.deleted.learning_memory_events', 1)
            ->assertJsonPath('data.child_summary.total_xp', 10)
            ->assertJsonPath('data.child_summary.streak_days', 1)
            ->assertJsonPath('data.child_summary.longest_streak', 1);

        $this->assertSame(0, LearningMemoryEvent::where('child_profile_id', (string) $child->_id)->count());
        $this->assertSame(1, RevisionSession::where('child_profile_id', (string) $child->_id)->count());
        $this->assertSame(1, GameResult::where('child_profile_id', (string) $child->_id)->count());
        $this->assertSame(1, MasteryProfile::where('child_profile_id', (string) $child->_id)->count());

        $all = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/memory/clear-scope', [
                'scope' => 'all',
            ]);

        $all->assertOk()
            ->assertJsonPath('data.scope', 'all')
            ->assertJsonPath('data.child_summary.total_xp', 0)
            ->assertJsonPath('data.child_summary.streak_days', 0)
            ->assertJsonPath('data.child_summary.longest_streak', 0);

        $this->assertSame(0, RevisionSession::where('child_profile_id', (string) $child->_id)->count());
        $this->assertSame(0, GameResult::where('child_profile_id', (string) $child->_id)->count());
        $this->assertSame(0, MasteryProfile::where('child_profile_id', (string) $child->_id)->count());

        $child->refresh();
        $this->assertSame('all', (string) $child->last_memory_reset_scope);
        $this->assertNotNull($child->last_memory_reset_at);
        $this->assertSame(0, (int) $child->total_xp);
        $this->assertSame(0, (int) $child->streak_days);
        $this->assertSame(0, (int) $child->longest_streak);
        $this->assertNull($child->last_activity_date);
    }
}
