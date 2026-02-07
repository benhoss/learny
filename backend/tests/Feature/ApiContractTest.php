<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\MasteryProfile;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ApiContractTest extends TestCase
{
    public function test_health_endpoint_contract(): void
    {
        Storage::fake('s3');
        Redis::shouldReceive('connection->ping')->once()->andReturn('PONG');

        $response = $this->getJson('/api/health');

        $response->assertOk()
            ->assertJsonStructure([
                'status',
                'checks' => [
                    'mongodb' => ['ok'],
                    'redis' => ['ok'],
                    'storage' => ['ok'],
                ],
            ]);
    }

    public function test_children_and_progress_contracts(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        MasteryProfile::factory()->create([
            'child_profile_id' => (string) $child->_id,
            'mastery_level' => 0.9,
            'concept_key' => 'fractions.addition',
            'concept_label' => 'Adding fractions',
            'next_review_at' => now()->subHour(),
        ]);

        $token = Auth::guard('api')->login($user);

        $children = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children');

        $children->assertOk()
            ->assertJsonStructure([
                'data' => [
                    ['name', 'grade_level', 'birth_year'],
                ],
            ]);

        $progress = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/progress');

        $progress->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'child_id',
                    'total_concepts',
                    'mastered_concepts',
                    'average_mastery',
                ],
            ]);

        $home = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/home-recommendations');
        $home->assertOk()
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

        $memory = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/memory/preferences');
        $memory->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'memory_personalization_enabled',
                    'recommendation_why_enabled',
                    'recommendation_why_level',
                    'last_memory_reset_at',
                    'last_memory_reset_scope',
                ],
            ]);
    }
}
