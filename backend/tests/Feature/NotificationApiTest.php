<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\NotificationEvent;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class NotificationApiTest extends TestCase
{
    public function test_preferences_merge_global_parent_defaults_with_child_overrides(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $update = $this->withHeader('Authorization', 'Bearer '.$token)
            ->putJson('/api/v1/children/'.$child->_id.'/notification-preferences', [
                'globalParentDefaults' => [
                    'channels' => [
                        'push' => true,
                        'email' => true,
                        'inApp' => true,
                    ],
                    'caps' => [
                        'daily' => 2,
                        'weekly' => 6,
                    ],
                    'timezone' => 'Europe/Amsterdam',
                ],
                'childOverrides' => [
                    'channels' => [
                        'email' => false,
                    ],
                ],
            ]);

        $update->assertOk()
            ->assertJsonPath('data.globalParentDefaults.channels.email', true)
            ->assertJsonPath('data.childOverrides.channels.email', false)
            ->assertJsonPath('data.effective.channels.push', true)
            ->assertJsonPath('data.effective.channels.email', false)
            ->assertJsonPath('data.effective.caps.daily', 2);
    }

    public function test_parent_cannot_access_notifications_for_non_owned_child(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $owner->_id,
        ]);
        $token = Auth::guard('api')->login($other);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/notification-preferences');

        $response->assertStatus(404);
    }

    public function test_parent_can_register_and_revoke_device_tokens(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $create = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/notification-devices', [
                'platform' => 'ios',
                'token' => 'dev-token-1',
                'locale' => 'en',
                'timezone' => 'Europe/Amsterdam',
            ]);

        $create->assertStatus(201)
            ->assertJsonPath('data.platform', 'ios')
            ->assertJsonPath('data.token', 'dev-token-1');

        $deviceId = $this->extractId($create->json('data'));
        $delete = $this->withHeader('Authorization', 'Bearer '.$token)
            ->deleteJson('/api/v1/children/'.$child->_id.'/notification-devices/'.$deviceId);

        $delete->assertOk()->assertJsonPath('data.revoked', true);
    }

    public function test_child_inbox_and_read_open_tracking_work(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $token = Auth::guard('api')->login($user);

        $event = NotificationEvent::create([
            'event_id' => 'ev-1',
            'source_event_id' => 'src-1',
            'campaign_key' => 'learning_pack_ready',
            'audience' => 'child',
            'recipient_user_id' => (string) $user->_id,
            'user_id' => (string) $user->_id,
            'child_id' => (string) $child->_id,
            'channel' => 'in_app',
            'dedupe_key' => 'k1',
            'idempotency_key' => 'id1',
            'status' => 'delivered',
            'priority' => 'normal',
            'context_payload' => [],
        ]);

        $inbox = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$child->_id.'/notifications');

        $inbox->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', (string) $event->_id)
            ->assertJsonStructure(['meta' => ['nextCursor']]);

        $markRead = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/notifications/'.$event->_id.'/read');
        $markRead->assertOk()->assertJsonPath('data.read', true);

        $markOpen = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children/'.$child->_id.'/notifications/'.$event->_id.'/open');
        $markOpen->assertOk()->assertJsonPath('data.opened', true);

        $event->refresh();
        $this->assertNotNull($event->read_at);
        $this->assertNotNull($event->opened_at);
        $this->assertSame('opened', (string) $event->status);
    }

    public function test_parent_inbox_is_self_scoped(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();
        $tokenA = Auth::guard('api')->login($userA);

        NotificationEvent::create([
            'event_id' => 'ev-a',
            'source_event_id' => 'src-a',
            'campaign_key' => 'weekly_progress_digest',
            'audience' => 'parent',
            'recipient_user_id' => (string) $userA->_id,
            'user_id' => (string) $userA->_id,
            'channel' => 'in_app',
            'dedupe_key' => 'k-a',
            'idempotency_key' => 'id-a',
            'status' => 'delivered',
            'context_payload' => [],
        ]);
        NotificationEvent::create([
            'event_id' => 'ev-b',
            'source_event_id' => 'src-b',
            'campaign_key' => 'weekly_progress_digest',
            'audience' => 'parent',
            'recipient_user_id' => (string) $userB->_id,
            'user_id' => (string) $userB->_id,
            'channel' => 'in_app',
            'dedupe_key' => 'k-b',
            'idempotency_key' => 'id-b',
            'status' => 'delivered',
            'context_payload' => [],
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$tokenA)
            ->getJson('/api/v1/notifications/parent-inbox');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.campaignKey', 'weekly_progress_digest');
    }
}
