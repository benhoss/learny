<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class MasteryProgressTest extends TestCase
{
    public function test_mastery_upsert_and_progress_summary(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'parent4@example.com',
            'password' => 'secret123',
        ]);

        $child = ChildProfile::create([
            'user_id' => (string) $user->_id,
            'name' => 'Riley',
            'grade_level' => '6th',
            'birth_year' => 2013,
        ]);

        $token = Auth::guard('api')->login($user);

        $upsert = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/mastery', [
                'concept_key' => 'fractions.addition.basic',
                'concept_label' => 'Adding fractions',
                'mastery_level' => 0.72,
                'total_attempts' => 14,
                'correct_attempts' => 10,
                'last_attempt_at' => now()->toISOString(),
            ]);

        $upsert->assertStatus(201)->assertJsonPath('data.concept_key', 'fractions.addition.basic');

        $list = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/mastery');

        $list->assertOk()->assertJsonCount(1, 'data');

        $progress = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/progress');

        $progress->assertOk()->assertJsonPath('data.total_concepts', 1);
    }
}
