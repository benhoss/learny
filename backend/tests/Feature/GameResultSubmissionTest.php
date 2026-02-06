<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\LearningMemoryEvent;
use App\Models\LearningPack;
use App\Models\MasteryProfile;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class GameResultSubmissionTest extends TestCase
{
    public function test_game_result_submission_is_idempotent_for_same_child_and_game(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
            'streak_days' => 0,
            'longest_streak' => 0,
            'total_xp' => 0,
            'last_activity_date' => null,
        ]);
        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
        ]);
        $pack = LearningPack::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'document_id' => (string) $document->_id,
            'title' => 'Fractions Pack',
            'summary' => 'Practice',
            'status' => 'ready',
            'schema_version' => 'v1',
            'content' => [
                'objective' => 'Understand fractions',
                'concepts' => [
                    ['key' => 'fractions.addition', 'label' => 'Adding fractions'],
                ],
                'items' => [],
            ],
        ]);
        $game = Game::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => (string) $pack->_id,
            'type' => 'quiz',
            'schema_version' => 'v1',
            'status' => 'ready',
            'payload' => [
                'title' => 'Quiz',
                'questions' => [
                    [
                        'prompt' => '1/2 + 1/2',
                        'choices' => ['1', '2'],
                        'answer_index' => 0,
                        'topic' => 'fractions.addition',
                    ],
                ],
            ],
        ]);

        $token = Auth::guard('api')->login($user);

        $payload = [
            'results' => [
                [
                    'correct' => true,
                    'prompt' => '1/2 + 1/2',
                    'topic' => 'fractions.addition',
                    'response' => '1',
                    'expected' => '1',
                ],
            ],
            'total_questions' => 1,
            'correct_answers' => 1,
            'completed_at' => now()->toIso8601String(),
        ];

        $first = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson(
                '/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/results',
                $payload
            );

        $first->assertStatus(201)
            ->assertJsonPath('idempotent_replay', false)
            ->assertJsonPath('xp_earned', 10);

        $second = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson(
                '/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/results',
                $payload
            );

        $second->assertStatus(201)
            ->assertJsonPath('idempotent_replay', true)
            ->assertJsonPath('xp_earned', 10);

        $this->assertSame(
            1,
            GameResult::where('child_profile_id', (string) $child->_id)
                ->where('game_id', (string) $game->_id)
                ->count()
        );

        $saved = GameResult::where('child_profile_id', (string) $child->_id)
            ->where('game_id', (string) $game->_id)
            ->first();
        $this->assertNotNull($saved);
        $this->assertSame(10, (int) $saved->xp_earned);

        $mastery = MasteryProfile::where('child_profile_id', (string) $child->_id)
            ->where('concept_key', 'fractions.addition')
            ->first();
        $this->assertNotNull($mastery);
        $this->assertSame(1, (int) $mastery->total_attempts);
        $this->assertSame(1, (int) $mastery->correct_attempts);
        $this->assertSame(
            1,
            LearningMemoryEvent::where('child_profile_id', (string) $child->_id)
                ->where('event_type', 'play')
                ->where('concept_key', 'fractions.addition')
                ->count()
        );

        $child->refresh();
        $this->assertSame(10, (int) $child->total_xp);
        $this->assertSame(1, (int) $child->streak_days);
        $this->assertSame(1, (int) $child->longest_streak);
    }
}
