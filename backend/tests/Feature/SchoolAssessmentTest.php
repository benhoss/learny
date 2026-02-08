<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\SchoolAssessment;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class SchoolAssessmentTest extends TestCase
{
    public function test_parent_can_crud_school_assessments_for_owned_child(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'assessments-parent@example.com',
            'password' => 'secret123',
        ]);

        $child = ChildProfile::create([
            'user_id' => (string) $user->_id,
            'name' => 'Nora',
            'grade_level' => '6th',
        ]);

        $token = Auth::guard('api')->login($user);

        $create = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.(string) $child->_id.'/school-assessments', [
                'subject' => 'Math',
                'assessment_type' => 'weekly_test',
                'score' => 16,
                'max_score' => 20,
                'grade' => 'B+',
                'assessed_at' => '2026-02-08T10:00:00Z',
                'teacher_note' => 'Good progress.',
                'source' => 'manual',
            ]);

        $create->assertStatus(201)
            ->assertJsonPath('data.subject', 'Math')
            ->assertJsonPath('data.score_percent', 80.0);

        $assessmentId = $this->extractId($create->json('data'));

        $index = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.(string) $child->_id.'/school-assessments');

        $index->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.assessment_type', 'weekly_test');

        $update = $this->withHeader('Authorization', 'Bearer '.$token)
            ->patchJson('/api/v1/children/'.(string) $child->_id.'/school-assessments/'.$assessmentId, [
                'score' => 18,
                'max_score' => 20,
                'source' => 'ocr',
            ]);

        $update->assertOk()
            ->assertJsonPath('data.score_percent', 90.0)
            ->assertJsonPath('data.source', 'ocr');

        $delete = $this->withHeader('Authorization', 'Bearer '.$token)
            ->deleteJson('/api/v1/children/'.(string) $child->_id.'/school-assessments/'.$assessmentId);

        $delete->assertOk();
        $this->assertEquals(0, SchoolAssessment::count());
    }

    public function test_rejects_score_above_max_score(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'assessments-parent-2@example.com',
            'password' => 'secret123',
        ]);

        $child = ChildProfile::create([
            'user_id' => (string) $user->_id,
            'name' => 'Nora',
        ]);

        $token = Auth::guard('api')->login($user);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.(string) $child->_id.'/school-assessments', [
                'subject' => 'French',
                'assessment_type' => 'dictation',
                'score' => 22,
                'max_score' => 20,
                'assessed_at' => '2026-02-08',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['score']);
    }

    public function test_parent_cannot_read_other_parents_child_assessments(): void
    {
        $owner = User::create([
            'name' => 'Owner',
            'email' => 'owner@example.com',
            'password' => 'secret123',
        ]);

        $otherUser = User::create([
            'name' => 'Other',
            'email' => 'other@example.com',
            'password' => 'secret123',
        ]);

        $child = ChildProfile::create([
            'user_id' => (string) $owner->_id,
            'name' => 'Owner Child',
        ]);

        SchoolAssessment::create([
            'child_profile_id' => (string) $child->_id,
            'subject' => 'Math',
            'assessment_type' => 'quiz',
            'score' => 8,
            'max_score' => 10,
            'assessed_at' => '2026-02-08',
        ]);

        $token = Auth::guard('api')->login($otherUser);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.(string) $child->_id.'/school-assessments');

        $response->assertStatus(404);
    }
}
