<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\GuestSession;
use App\Models\LearningPack;
use App\Models\OnboardingEvent;
use App\Models\QuizSession;
use App\Models\RevisionSession;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class GuestSessionLinkingTest extends TestCase
{
    public function test_can_create_guest_session_and_record_event(): void
    {
        $response = $this->postJson('/api/v1/guest/session', [
            'device_signature' => 'device-abc-12345',
            'instance_id' => 'instance-1',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.state', 'guest_prelink')
            ->assertJsonPath('data.token_type', 'bearer');

        $sessionId = (string) $response->json('data.guest_session_id');
        $guestChildId = (string) $response->json('data.guest_child_id');
        $this->assertNotSame('', $sessionId);
        $this->assertNotSame('', $guestChildId);
        $this->assertNotNull(GuestSession::where('session_id', $sessionId)->first());
        $this->assertSame(
            1,
            OnboardingEvent::where('event_name', 'guest_session_started')
                ->where('role', 'guest')
                ->where('guest_session_id', $sessionId)
                ->count()
        );
    }

    public function test_guest_link_account_migrates_owned_artifacts_and_is_idempotent(): void
    {
        $session = GuestSession::create([
            'session_id' => 'guest_test_session',
            'device_signature_hash' => hash('sha256', 'device-x'),
            'state' => 'guest_prelink',
            'first_seen_at' => now(),
            'last_seen_at' => now(),
        ]);

        Document::factory()->create([
            'owner_type' => 'guest',
            'owner_guest_session_id' => $session->session_id,
            'owner_child_id' => null,
            'user_id' => null,
            'child_profile_id' => null,
        ]);
        $pack = LearningPack::factory()->create([
            'owner_type' => 'guest',
            'owner_guest_session_id' => $session->session_id,
            'owner_child_id' => null,
            'user_id' => null,
            'child_profile_id' => null,
        ]);
        $game = Game::factory()->create([
            'owner_type' => 'guest',
            'owner_guest_session_id' => $session->session_id,
            'owner_child_id' => null,
            'user_id' => null,
            'child_profile_id' => null,
            'learning_pack_id' => (string) $pack->_id,
        ]);
        GameResult::create([
            'owner_type' => 'guest',
            'owner_guest_session_id' => $session->session_id,
            'owner_child_id' => null,
            'user_id' => null,
            'child_profile_id' => null,
            'learning_pack_id' => (string) $pack->_id,
            'game_id' => (string) $game->_id,
            'game_type' => 'quiz',
            'schema_version' => 'v1',
            'results' => [
                ['correct' => true],
            ],
            'score' => 1,
            'total_questions' => 1,
            'correct_answers' => 1,
            'xp_earned' => 10,
            'metadata' => [],
            'completed_at' => now(),
        ]);
        QuizSession::create([
            'owner_type' => 'guest',
            'owner_guest_session_id' => $session->session_id,
            'owner_child_id' => null,
            'user_id' => null,
            'child_profile_id' => null,
            'learning_pack_id' => (string) $pack->_id,
            'game_id' => (string) $game->_id,
            'status' => 'active',
            'requested_question_count' => 1,
            'available_question_count' => 1,
            'question_indices' => [0],
            'current_index' => 0,
            'correct_count' => 0,
            'results' => [],
            'started_at' => now(),
            'last_interaction_at' => now(),
        ]);
        RevisionSession::create([
            'owner_type' => 'guest',
            'owner_guest_session_id' => $session->session_id,
            'owner_child_id' => null,
            'user_id' => null,
            'child_profile_id' => null,
            'source' => 'mixed',
            'status' => 'active',
            'started_at' => now(),
            'total_items' => 1,
            'correct_items' => 0,
            'xp_earned' => 0,
            'subject_label' => 'Quick Revision',
            'duration_minutes' => 5,
            'items' => [],
            'results' => [],
        ]);

        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $link = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/guest/link-account', [
                'guest_session_id' => (string) $session->session_id,
                'child_id' => (string) $child->_id,
            ]);

        $link->assertOk()
            ->assertJsonPath('data.idempotent_replay', false)
            ->assertJsonPath('data.linked', true)
            ->assertJsonPath('data.migration_summary.documents', 1)
            ->assertJsonPath('data.migration_summary.learning_packs', 1)
            ->assertJsonPath('data.migration_summary.games', 1)
            ->assertJsonPath('data.migration_summary.game_results', 1)
            ->assertJsonPath('data.migration_summary.quiz_sessions', 1)
            ->assertJsonPath('data.migration_summary.revision_sessions', 1);

        $this->assertSame(
            1,
            OnboardingEvent::where('event_name', 'guest_session_linked')
                ->where('role', 'guest')
                ->where('guest_session_id', (string) $session->session_id)
                ->count()
        );

        $again = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/guest/link-account', [
                'guest_session_id' => (string) $session->session_id,
                'child_id' => (string) $child->_id,
            ]);

        $again->assertOk()
            ->assertJsonPath('data.idempotent_replay', true);
    }
}
