<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\Game;
use App\Models\LearningPack;
use App\Models\QuizSession;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class QuizSessionTest extends TestCase
{
    public function test_quiz_session_can_be_created_updated_and_resumed(): void
    {
        [$child, $pack, $game, $token] = $this->seedQuizGame();

        $start = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/quiz-sessions', [
                'question_count' => 5,
            ]);

        $start->assertCreated()
            ->assertJsonPath('idempotent_replay', false)
            ->assertJsonPath('data.status', 'active')
            ->assertJsonCount(5, 'data.question_indices');

        $sessionId = (string) $start->json('data.id');

        $update = $this->withHeader('Authorization', 'Bearer '.$token)
            ->patchJson('/api/v1/children/'.$child->_id.'/quiz-sessions/'.$sessionId, [
                'current_index' => 2,
                'correct_count' => 1,
                'results' => [
                    [
                        'correct' => true,
                        'prompt' => 'Question 1',
                        'topic' => 'fractions.addition',
                        'response' => 'A',
                        'expected' => 'A',
                    ],
                    [
                        'correct' => false,
                        'prompt' => 'Question 2',
                        'topic' => 'fractions.subtraction',
                        'response' => 'B',
                        'expected' => 'C',
                    ],
                ],
                'status' => 'paused',
            ]);

        $update->assertOk()
            ->assertJsonPath('data.status', 'paused')
            ->assertJsonPath('data.current_index', 2)
            ->assertJsonPath('data.correct_count', 1)
            ->assertJsonCount(2, 'data.results');

        $active = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/quiz-sessions/active');

        $active->assertOk()
            ->assertJsonPath('data.id', $sessionId)
            ->assertJsonPath('data.status', 'paused')
            ->assertJsonPath('data.current_index', 2);
    }

    public function test_create_quiz_session_is_idempotent_when_active_exists_for_same_game(): void
    {
        [$child, $pack, $game, $token] = $this->seedQuizGame();

        $first = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/quiz-sessions', [
                'question_count' => 6,
            ]);

        $sessionId = (string) $first->json('data.id');

        $second = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/quiz-sessions', [
                'question_count' => 8,
            ]);

        $second->assertOk()
            ->assertJsonPath('idempotent_replay', true)
            ->assertJsonPath('data.id', $sessionId)
            ->assertJsonPath('data.requested_question_count', 6);

        $this->assertSame(
            1,
            QuizSession::where('child_profile_id', (string) $child->_id)
                ->where('game_id', (string) $game->_id)
                ->count()
        );
    }

    public function test_quiz_session_rejects_question_count_outside_bounds(): void
    {
        [$child, $pack, $game, $token] = $this->seedQuizGame();

        $tooLow = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/quiz-sessions', [
                'question_count' => 4,
            ]);
        $tooLow->assertStatus(422);

        $tooHigh = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/quiz-sessions', [
                'question_count' => 21,
            ]);
        $tooHigh->assertStatus(422);
    }

    public function test_quiz_session_rejects_request_larger_than_available_questions(): void
    {
        [$child, $pack, $game, $token] = $this->seedQuizGame(questionCount: 6);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/learning-packs/'.$pack->_id.'/games/'.$game->_id.'/quiz-sessions', [
                'question_count' => 7,
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.question_count.0', 'Requested question count exceeds available quiz questions.');
    }

    /**
     * @return array{0: ChildProfile, 1: LearningPack, 2: Game, 3: string}
     */
    protected function seedQuizGame(int $questionCount = 10): array
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
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
            'summary' => 'Practice fractions',
            'status' => 'ready',
            'schema_version' => 'v1',
            'content' => [
                'objective' => 'Practice fractions',
                'concepts' => [
                    ['key' => 'fractions.addition', 'label' => 'Addition'],
                    ['key' => 'fractions.subtraction', 'label' => 'Subtraction'],
                ],
                'items' => [],
            ],
        ]);

        $questions = [];
        for ($index = 0; $index < $questionCount; $index += 1) {
            $questions[] = [
                'id' => 'q-'.($index + 1),
                'prompt' => 'Question '.($index + 1),
                'choices' => ['A', 'B', 'C', 'D'],
                'answer_index' => $index % 4,
                'topic' => $index % 2 === 0 ? 'fractions.addition' : 'fractions.subtraction',
            ];
        }

        $game = Game::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => (string) $pack->_id,
            'type' => 'quiz',
            'schema_version' => 'v1',
            'status' => 'ready',
            'payload' => [
                'title' => 'Quick Quiz',
                'questions' => $questions,
            ],
        ]);

        $token = Auth::guard('api')->login($user);

        return [$child, $pack, $game, $token];
    }
}
