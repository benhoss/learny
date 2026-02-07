<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\GameResult;
use App\Models\LearningPack;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class ActivityFeedTest extends TestCase
{
    public function test_activities_endpoint_supports_page_contract_and_load_more(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        $document = Document::factory()->create([
            'user_id' => (string) $user->_id,
            'child_profile_id' => (string) $child->_id,
            'subject' => 'Math',
            'original_filename' => 'fractions.pdf',
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
                'objective' => 'Master fractions',
                'concepts' => [
                    ['key' => 'fractions.basics', 'label' => 'Fractions basics'],
                ],
                'items' => [],
            ],
        ]);

        for ($index = 1; $index <= 23; $index++) {
            $correctAnswers = $index % 5;
            $totalQuestions = 5;
            GameResult::create([
                'user_id' => (string) $user->_id,
                'child_profile_id' => (string) $child->_id,
                'learning_pack_id' => (string) $pack->_id,
                'game_id' => 'game-'.$index,
                'game_type' => 'quiz',
                'schema_version' => 'v1',
                'game_payload' => [],
                'results' => [],
                'score' => $correctAnswers / $totalQuestions,
                'total_questions' => $totalQuestions,
                'correct_answers' => $correctAnswers,
                'xp_earned' => $correctAnswers * 10,
                'language' => 'en',
                'metadata' => [],
                'completed_at' => now()->subMinutes($index),
            ]);
        }

        $token = Auth::guard('api')->login($user);

        $page1 = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/activities?page=1&per_page=10');
        $page1->assertStatus(200)
            ->assertJsonPath('meta.page', 1)
            ->assertJsonPath('meta.per_page', 10)
            ->assertJsonPath('meta.has_more', true)
            ->assertJsonPath('meta.next_page', 2);

        $page2 = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/activities?page=2&per_page=10');
        $page2->assertStatus(200)
            ->assertJsonPath('meta.page', 2)
            ->assertJsonPath('meta.per_page', 10)
            ->assertJsonPath('meta.has_more', true)
            ->assertJsonPath('meta.next_page', 3);

        $page3 = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/activities?page=3&per_page=10');
        $page3->assertStatus(200)
            ->assertJsonPath('meta.page', 3)
            ->assertJsonPath('meta.per_page', 10)
            ->assertJsonPath('meta.has_more', false)
            ->assertJsonPath('meta.next_page', null);

        $data1 = $page1->json('data');
        $data2 = $page2->json('data');
        $data3 = $page3->json('data');

        $this->assertCount(10, $data1);
        $this->assertCount(10, $data2);
        $this->assertCount(3, $data3);

        $ids1 = array_map(fn (array $row) => (string) $row['id'], $data1);
        $ids2 = array_map(fn (array $row) => (string) $row['id'], $data2);
        $ids3 = array_map(fn (array $row) => (string) $row['id'], $data3);

        $this->assertSame([], array_values(array_intersect($ids1, $ids2)));
        $this->assertSame([], array_values(array_intersect($ids1, $ids3)));
        $this->assertSame([], array_values(array_intersect($ids2, $ids3)));
    }
}

