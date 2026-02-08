<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::connection('mongodb')->table('school_assessments', function ($collection) {
            $collection->index(['child_profile_id', 'assessed_at']);
        });
    }

    public function down(): void
    {
        // Indexes can be dropped manually via MongoDB shell if needed.
    }
};
