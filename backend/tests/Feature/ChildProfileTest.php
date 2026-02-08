<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class ChildProfileTest extends TestCase
{
    use WithFaker;

    public function test_parent_can_crud_child_profiles(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'parent3@example.com',
            'password' => 'secret123',
        ]);

        $token = Auth::guard('api')->login($user);

        $create = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children', [
                'name' => 'Jamie',
                'grade_level' => '5th',
                'birth_year' => 2014,
                'school_class' => 'Year 5',
                'preferred_language' => 'en',
                'gender' => 'prefer_not_to_say',
                'learning_style_preferences' => ['visual', 'short_bursts'],
                'support_needs' => [
                    'attention_support' => true,
                    'dyslexia_friendly_mode' => false,
                ],
                'confidence_by_subject' => [
                    ['subject' => 'Math', 'confidence_level' => 2],
                    ['subject' => 'Science', 'confidence_level' => 4],
                ],
                'notes' => 'Needs help with fractions.',
            ]);

        $create->assertStatus(201)
            ->assertJsonPath('data.school_class', 'Year 5')
            ->assertJsonPath('data.preferred_language', 'en')
            ->assertJsonPath('data.learning_style_preferences.0', 'visual')
            ->assertJsonPath('data.confidence_by_subject.0.subject', 'Math')
            ->assertJsonPath('data.age', now()->year - 2014);

        $childId = $this->extractId($create->json('data'));

        $index = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children');
        $index->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.age', now()->year - 2014);

        $update = $this->withHeader('Authorization', 'Bearer '.$token)
            ->patchJson('/api/v1/children/'.$childId, [
                'grade_level' => '6th',
                'preferred_language' => 'fr',
            ]);
        $update->assertOk()
            ->assertJsonPath('data.grade_level', '6th')
            ->assertJsonPath('data.preferred_language', 'fr');

        $delete = $this->withHeader('Authorization', 'Bearer '.$token)
            ->deleteJson('/api/v1/children/'.$childId);
        $delete->assertOk();

        $this->assertEquals(0, ChildProfile::count());
    }


    public function test_rejects_gender_self_description_without_self_describe_gender(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'parent5@example.com',
            'password' => 'secret123',
        ]);

        $token = Auth::guard('api')->login($user);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children', [
                'name' => 'Jamie',
                'gender' => 'female',
                'gender_self_description' => 'Learner-defined',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['gender_self_description']);
    }

    public function test_update_clears_gender_self_description_when_gender_changes(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'parent6@example.com',
            'password' => 'secret123',
        ]);

        $token = Auth::guard('api')->login($user);

        $create = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children', [
                'name' => 'Jamie',
                'gender' => 'self_describe',
                'gender_self_description' => 'Questioning',
            ]);

        $childId = $this->extractId($create->json('data'));

        $update = $this->withHeader('Authorization', 'Bearer '.$token)
            ->patchJson('/api/v1/children/'.$childId, [
                'gender' => 'male',
            ]);

        $update->assertOk()
            ->assertJsonPath('data.gender', 'male')
            ->assertJsonPath('data.gender_self_description', null);
    }

    public function test_rejects_unknown_support_need_keys(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'parent4@example.com',
            'password' => 'secret123',
        ]);

        $token = Auth::guard('api')->login($user);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children', [
                'name' => 'Jamie',
                'support_needs' => [
                    'unknown_key' => true,
                ],
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['support_needs']);
    }
}
