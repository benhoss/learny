<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('quiz_sessions', function ($collection) {
            $collection->index(['child_profile_id', 'status', 'last_interaction_at']);
            $collection->index(['child_profile_id', 'game_id', 'status']);
        });
    }

    public function down(): void
    {
        // Indexes can be dropped manually if needed.
    }
};
