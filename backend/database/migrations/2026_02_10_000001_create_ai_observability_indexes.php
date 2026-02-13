<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('ai_generation_runs', function ($collection) {
            $collection->index(['correlation_id'], 'ai_generation_runs_correlation_id_idx');
            $collection->index(['feature_name', 'started_at'], 'ai_generation_runs_feature_started_at_idx');
            $collection->index(['document_id', 'started_at'], 'ai_generation_runs_document_started_at_idx');
            $collection->index(['child_profile_id', 'started_at'], 'ai_generation_runs_child_profile_started_at_idx');
            $collection->index(['final_status', 'completed_at'], 'ai_generation_runs_final_status_completed_at_idx');
        });

        Schema::connection('mongodb')->table('ai_generation_artifacts', function ($collection) {
            $collection->index(['run_id', 'artifact_type'], 'ai_generation_artifacts_run_type_idx');
            $collection->index(['content_hash'], 'ai_generation_artifacts_content_hash_idx');
        });

        Schema::connection('mongodb')->table('ai_guardrail_results', function ($collection) {
            $collection->index(['run_id', 'check_name'], 'ai_guardrail_results_run_check_idx');
            $collection->index(['result', 'created_at'], 'ai_guardrail_results_result_created_at_idx');
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->table('ai_generation_runs', function ($collection) {
            $collection->dropIndex('ai_generation_runs_correlation_id_idx');
            $collection->dropIndex('ai_generation_runs_feature_started_at_idx');
            $collection->dropIndex('ai_generation_runs_document_started_at_idx');
            $collection->dropIndex('ai_generation_runs_child_profile_started_at_idx');
            $collection->dropIndex('ai_generation_runs_final_status_completed_at_idx');
        });

        Schema::connection('mongodb')->table('ai_generation_artifacts', function ($collection) {
            $collection->dropIndex('ai_generation_artifacts_run_type_idx');
            $collection->dropIndex('ai_generation_artifacts_content_hash_idx');
        });

        Schema::connection('mongodb')->table('ai_guardrail_results', function ($collection) {
            $collection->dropIndex('ai_guardrail_results_run_check_idx');
            $collection->dropIndex('ai_guardrail_results_result_created_at_idx');
        });
    }
};
