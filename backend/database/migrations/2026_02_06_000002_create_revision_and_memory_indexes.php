<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('revision_sessions', function ($collection) {
            $collection->index(['child_profile_id', 'status']);
            $collection->index(['child_profile_id', 'created_at']);
        });

        Schema::connection('mongodb')->table('learning_memory_events', function ($collection) {
            $collection->index(['child_profile_id', 'concept_key', 'occurred_at']);
            $collection->index(['child_profile_id', 'event_type', 'occurred_at']);
            $collection->index(['source_type', 'source_id']);
        });
    }

    public function down(): void
    {
        // Indexes can be dropped manually if needed.
    }
};
