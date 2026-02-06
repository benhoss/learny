<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('mastery_profiles', function ($collection) {
            $collection->unique(['child_profile_id', 'concept_key']);
            $collection->index(['child_profile_id', 'next_review_at']);
        });

        Schema::connection('mongodb')->table('child_profiles', function ($collection) {
            $collection->index('user_id');
        });

        Schema::connection('mongodb')->table('games', function ($collection) {
            $collection->index(['learning_pack_id', 'child_profile_id']);
        });

        Schema::connection('mongodb')->table('game_results', function ($collection) {
            $collection->index(['user_id', 'child_profile_id']);
        });

        Schema::connection('mongodb')->table('learning_packs', function ($collection) {
            $collection->index(['child_profile_id', 'document_id']);
        });
    }

    public function down(): void
    {
        // Indexes can be dropped manually via MongoDB shell if needed.
    }
};
