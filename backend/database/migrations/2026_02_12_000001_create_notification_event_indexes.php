<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('notification_events', function ($collection) {
            $collection->unique('idempotency_key');
            $collection->index(['dedupe_key', 'scheduled_for']);
            $collection->index(['recipient_user_id', 'status', 'sent_at']);
            $collection->index(['campaign_key', 'status', 'sent_at']);
            $collection->index(['recipient_user_id', 'child_id', 'channel', 'created_at']);
        });

        Schema::connection('mongodb')->table('notification_preferences', function ($collection) {
            $collection->unique(['user_id', 'child_id']);
        });

        Schema::connection('mongodb')->table('device_tokens', function ($collection) {
            $collection->index(['user_id', 'child_id', 'revoked_at']);
            $collection->index(['token']);
        });
    }

    public function down(): void
    {
        // Indexes can be dropped manually via MongoDB shell if needed.
    }
};
