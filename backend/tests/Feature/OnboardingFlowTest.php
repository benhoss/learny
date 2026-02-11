<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\OnboardingEvent;
use App\Models\OnboardingLinkToken;
use App\Models\OnboardingState;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class OnboardingFlowTest extends TestCase
{
    public function test_parent_can_save_and_resume_onboarding_state(): void
    {
        $user = User::factory()->create();
        $token = Auth::guard('api')->login($user);

        $save = $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/onboarding/state', [
                'role' => 'parent',
                'current_step' => 'add_children',
                'checkpoints' => [
                    'child_count' => 1,
                ],
                'completed_steps' => ['parent_signup'],
            ]);

        $save->assertOk()
            ->assertJsonPath('data.role', 'parent')
            ->assertJsonPath('data.current_step', 'add_children');

        $show = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/onboarding/state');

        $show->assertOk()
            ->assertJsonPath('data.parent.current_step', 'add_children')
            ->assertJsonPath('data.parent.completed_steps.0', 'parent_signup');
    }

    public function test_onboarding_events_are_recorded_once_per_event_name(): void
    {
        $user = User::factory()->create();
        $token = Auth::guard('api')->login($user);

        $first = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/onboarding/events', [
                'role' => 'child',
                'event_name' => 'first_learning_completed',
                'step' => 'first_challenge',
            ]);

        $first->assertStatus(201)
            ->assertJsonPath('data.recorded', true);

        $second = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/onboarding/events', [
                'role' => 'child',
                'event_name' => 'first_learning_completed',
                'step' => 'first_challenge',
            ]);

        $second->assertOk()
            ->assertJsonPath('data.recorded', false);

        $this->assertSame(1, OnboardingEvent::count());

        $state = OnboardingState::where('user_id', (string) $user->_id)
            ->where('role', 'child')
            ->first();

        $this->assertNotNull($state);
        $this->assertCount(1, $state->completed_events ?? []);
    }

    public function test_child_completion_requires_parent_link_for_under_consent_age(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
            'linked_devices' => [],
        ]);

        $token = Auth::guard('api')->login($user);

        $blocked = $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/onboarding/state', [
                'role' => 'child',
                'current_step' => 'completed',
                'checkpoints' => [
                    'age_bracket' => '10-11',
                    'market' => 'US',
                    'child_id' => (string) $child->_id,
                ],
                'mark_complete' => true,
            ]);

        $blocked->assertStatus(422)->assertJsonValidationErrors(['consent']);

        $child->linked_devices = [
            [
                'id' => 'dev-1',
                'name' => 'Parent Approved Device',
                'platform' => 'ios',
            ],
        ];
        $child->save();

        $allowed = $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/onboarding/state', [
                'role' => 'child',
                'current_step' => 'completed',
                'checkpoints' => [
                    'age_bracket' => '10-11',
                    'market' => 'US',
                    'child_id' => (string) $child->_id,
                ],
                'mark_complete' => true,
            ]);

        $allowed->assertOk()->assertJsonPath('data.current_step', 'completed');
    }

    public function test_child_completion_checks_linked_device_for_target_child_only(): void
    {
        $user = User::factory()->create();
        $childWithoutLink = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
            'linked_devices' => [],
        ]);
        ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
            'linked_devices' => [
                [
                    'id' => 'dev-1',
                    'name' => 'Sibling Parent Device',
                    'platform' => 'ios',
                ],
            ],
        ]);

        $token = Auth::guard('api')->login($user);

        $blocked = $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/onboarding/state', [
                'role' => 'child',
                'current_step' => 'completed',
                'checkpoints' => [
                    'age_bracket' => '10-11',
                    'market' => 'US',
                    'child_id' => (string) $childWithoutLink->_id,
                ],
                'mark_complete' => true,
            ]);

        $blocked->assertStatus(422)->assertJsonValidationErrors(['consent']);
    }

    public function test_parent_can_generate_code_consume_link_and_revoke_device(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        $token = Auth::guard('api')->login($user);

        $create = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/onboarding/link-tokens', [
                'child_id' => (string) $child->_id,
            ]);

        $create->assertStatus(201)
            ->assertJsonStructure([
                'data' => ['token_id', 'child_id', 'code', 'expires_at'],
            ]);

        $code = (string) $create->json('data.code');

        $consume = $this->postJson('/api/v1/onboarding/link-tokens/consume', [
            'code' => $code,
            'child_id' => (string) $child->_id,
            'device_name' => 'Alex iPhone',
            'device_platform' => 'ios',
        ]);

        $consume->assertOk()
            ->assertJsonPath('data.child_id', (string) $child->_id)
            ->assertJsonPath('data.linked', true);

        $this->assertSame(1, OnboardingLinkToken::whereNotNull('consumed_at')->count());

        $list = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/devices');

        $list->assertOk()->assertJsonCount(1, 'data');
        $deviceId = (string) $list->json('data.0.id');

        $revoke = $this->withHeader('Authorization', 'Bearer '.$token)
            ->deleteJson('/api/v1/children/'.$child->_id.'/devices/'.$deviceId);

        $revoke->assertOk()->assertJsonPath('data.revoked', true);

        $listAfter = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/devices');
        $listAfter->assertOk()->assertJsonCount(0, 'data');

        $consumeAgain = $this->postJson('/api/v1/onboarding/link-tokens/consume', [
            'code' => $code,
            'child_id' => (string) $child->_id,
            'device_name' => 'Alex iPad',
            'device_platform' => 'ios',
        ]);

        $consumeAgain->assertStatus(422);
    }
}
