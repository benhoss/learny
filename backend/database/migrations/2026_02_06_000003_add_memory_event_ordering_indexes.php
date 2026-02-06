<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('learning_memory_events', function ($collection) {
            $collection->unique('event_key');
            $collection->index(['child_profile_id', 'event_order']);
        });
    }

    public function down(): void
    {
        // Indexes can be dropped manually if needed.
    }
};
