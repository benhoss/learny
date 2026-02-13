<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('ai_generation_runs', function ($collection) {
            $collection->index(['correlation_id']);
            $collection->index(['feature_name', 'started_at']);
            $collection->index(['document_id', 'started_at']);
            $collection->index(['child_profile_id', 'started_at']);
            $collection->index(['final_status', 'completed_at']);
        });

        Schema::connection('mongodb')->table('ai_generation_artifacts', function ($collection) {
            $collection->index(['run_id', 'artifact_type']);
            $collection->index(['content_hash']);
        });

        Schema::connection('mongodb')->table('ai_guardrail_results', function ($collection) {
            $collection->index(['run_id', 'check_name']);
            $collection->index(['result', 'created_at']);
        });
    }

    public function down(): void
    {
        // Indexes can be dropped manually if needed.
    }
};
