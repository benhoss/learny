<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\MasteryProfile;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ApiContractTest extends TestCase
{
    public function test_health_endpoint_contract(): void
    {
        Storage::fake('s3');

        $response = $this->getJson('/api/health');

        $response->assertOk()
            ->assertJsonStructure([
                'status',
                'checks' => [
                    'mongodb' => ['ok'],
                    'redis' => ['ok'],
                    's3' => ['ok'],
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
    }
}
