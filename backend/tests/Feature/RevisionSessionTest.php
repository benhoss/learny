<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\GameResult;
use App\Models\LearningMemoryEvent;
use App\Models\LearningPack;
use App\Models\MasteryProfile;
use App\Models\RevisionSession;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class RevisionSessionTest extends TestCase
{
    public function test_revision_session_can_be_composed_and_submitted(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'status' => 'processed',
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
                    ['key' => 'fractions.subtraction', 'label' => 'Subtracting fractions'],
                ],
                'items' => [],
            ],
        ]);

        MasteryProfile::create([
            'child_profile_id' => (string) $child->_id,
            'concept_key' => 'fractions.addition',
            'concept_label' => 'Adding fractions',
            'mastery_level' => 0.4,
            'total_attempts' => 5,
            'correct_attempts' => 2,
            'next_review_at' => now()->subHour(),
        ]);

        GameResult::create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'learning_pack_id' => (string) $pack->_id,
            'game_id' => 'game-1',
            'game_type' => 'quiz',
            'schema_version' => 'v1',
            'game_payload' => [],
            'results' => [
                [
                    'correct' => false,
                    'prompt' => '1/2 + 1/3 = ?',
                    'topic' => 'fractions.addition',
                    'response' => '2/5',
                    'expected' => '5/6',
                ],
            ],
            'score' => 0.0,
            'total_questions' => 1,
            'correct_answers' => 0,
            'xp_earned' => 0,
            'metadata' => [],
            'completed_at' => now()->subMinutes(5),
        ]);

        $token = Auth::guard('api')->login($user);

        $start = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/revision-session?limit=5');

        $start->assertOk()
            ->assertJsonPath('idempotent_replay', false)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'items' => [
                        ['id', 'prompt', 'options', 'correct_index'],
                    ],
                ],
            ]);

        $sessionId = (string) $start->json('data.id');
        $items = collect($start->json('data.items'));
        $this->assertNotEmpty($items->all());

        $results = $items->take(3)->map(function (array $item) {
            return [
                'item_id' => (string) $item['id'],
                'selected_index' => (int) $item['correct_index'],
                'latency_ms' => 1200,
            ];
        })->values()->all();

        $submit = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/revision-session/'.$sessionId, [
                'results' => $results,
            ]);

        $submit->assertOk()
            ->assertJsonPath('idempotent_replay', false)
            ->assertJsonPath('data.status', 'completed')
            ->assertJsonPath('data.correct_items', count($results));

        $this->assertSame(1, RevisionSession::where('_id', $sessionId)->count());
        $eventCount = LearningMemoryEvent::where('child_profile_id', (string) $child->_id)
            ->where('event_type', 'review')
            ->count();
        $this->assertGreaterThan(
            0,
            $eventCount
        );

        $replay = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/revision-session/'.$sessionId, [
                'results' => $results,
            ]);

        $replay->assertOk()
            ->assertJsonPath('idempotent_replay', true);

        $this->assertSame(
            $eventCount,
            LearningMemoryEvent::where('child_profile_id', (string) $child->_id)
                ->where('event_type', 'review')
                ->count()
        );
    }
}
