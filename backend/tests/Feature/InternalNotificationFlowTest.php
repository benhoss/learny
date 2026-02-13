<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\NotificationEvent;
use App\Models\User;
use Tests\TestCase;

class InternalNotificationFlowTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        config()->set('learny.notifications.internal_token', 'test-internal-token');
    }

    public function test_internal_auth_rejects_invalid_token(): void
    {
        $response = $this->postJson('/internal/notifications/simulate', [
            'source_event_id' => 'src-1',
            'campaign_key' => 'learning_reminder_due',
            'audience' => 'child',
            'priority' => 'normal',
            'channels' => ['push'],
            'child_id' => 'child-1',
        ]);

        $response->assertStatus(401);
    }

    public function test_consent_missing_suppresses_child_push_email_and_active_session_defers_in_app(): void
    {
        $user = User::factory()->create();
        $child = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        $trigger = $this->withHeader('X-Internal-Token', 'test-internal-token')
            ->postJson('/internal/notifications/trigger', [
                'source_event_id' => 'source-1',
                'campaign_key' => 'learning_reminder_due',
                'audience' => 'child',
                'priority' => 'normal',
                'channels' => ['push', 'email', 'in_app'],
                'child_id' => (string) $child->_id,
                'consent_state' => 'missing',
                'market' => 'US',
                'is_child_active_in_session' => true,
            ]);

        $trigger->assertOk()->assertJsonCount(3, 'data.created');

        $events = NotificationEvent::orderBy('channel')->get()->keyBy('channel');
        $this->assertSame('suppressed', (string) $events['email']->status);
        $this->assertSame('suppressed', (string) $events['push']->status);
        $this->assertSame('queued', (string) $events['in_app']->status);
        $this->assertNotNull($events['in_app']->scheduled_for);
    }

    public function test_trigger_is_idempotent_and_parent_dedupe_does_not_cross_users(): void
    {
        $parentA = User::factory()->create();
        $parentB = User::factory()->create();

        $first = $this->withHeader('X-Internal-Token', 'test-internal-token')
            ->postJson('/internal/notifications/trigger', [
                'source_event_id' => 'source-parent',
                'campaign_key' => 'weekly_progress_digest',
                'audience' => 'parent',
                'priority' => 'normal',
                'channels' => ['in_app'],
                'recipient_user_id' => (string) $parentA->_id,
                'consent_state' => 'verified',
                'market' => 'US',
            ]);
        $first->assertOk()->assertJsonCount(1, 'data.created');

        $idempotent = $this->withHeader('X-Internal-Token', 'test-internal-token')
            ->postJson('/internal/notifications/trigger', [
                'source_event_id' => 'source-parent',
                'campaign_key' => 'weekly_progress_digest',
                'audience' => 'parent',
                'priority' => 'normal',
                'channels' => ['in_app'],
                'recipient_user_id' => (string) $parentA->_id,
                'consent_state' => 'verified',
                'market' => 'US',
            ]);
        $idempotent->assertOk()->assertJsonCount(1, 'data.existing');

        $secondParent = $this->withHeader('X-Internal-Token', 'test-internal-token')
            ->postJson('/internal/notifications/trigger', [
                'source_event_id' => 'source-parent',
                'campaign_key' => 'weekly_progress_digest',
                'audience' => 'parent',
                'priority' => 'normal',
                'channels' => ['in_app'],
                'recipient_user_id' => (string) $parentB->_id,
                'consent_state' => 'verified',
                'market' => 'US',
            ]);
        $secondParent->assertOk()->assertJsonCount(1, 'data.created');

        $this->assertSame(2, NotificationEvent::count());
    }

    public function test_retry_sets_failed_terminal_and_stops_future_retries(): void
    {
        config()->set('learny.notifications.max_retry_attempts', 3);

        $event = NotificationEvent::create([
            'event_id' => 'ev-1',
            'source_event_id' => 'src-1',
            'campaign_key' => 'consent_or_security_alert',
            'audience' => 'parent',
            'recipient_user_id' => 'parent-1',
            'user_id' => 'parent-1',
            'child_id' => null,
            'channel' => 'push',
            'dedupe_key' => 'dedupe-1',
            'idempotency_key' => 'idem-1',
            'status' => 'failed',
            'priority' => 'critical',
            'context_payload' => ['attempts' => 2],
            'consent_state' => 'verified',
            'policy_version' => 'v1',
        ]);

        $retry = $this->withHeader('X-Internal-Token', 'test-internal-token')
            ->postJson('/internal/notifications/retry/'.$event->_id, [
                'force_fail' => true,
            ]);

        $retry->assertOk()->assertJsonPath('data.status', 'failed_terminal');

        $event->refresh();
        $this->assertNotNull($event->failed_terminal_at);
        $this->assertSame('failed_terminal', (string) $event->status);
        $this->assertSame(2, NotificationEvent::count());

        $blocked = $this->withHeader('X-Internal-Token', 'test-internal-token')
            ->postJson('/internal/notifications/retry/'.$event->_id, [
                'force_fail' => true,
            ]);

        $blocked->assertStatus(409);
    }
}
