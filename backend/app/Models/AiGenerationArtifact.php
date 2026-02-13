<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class AiGenerationArtifact extends Model
{
    use HasFactory;

    protected $collection = 'ai_generation_artifacts';

    protected $fillable = [
        'run_id',
        'artifact_type',
        'content_encrypted',
        'content_hash',
        'schema_name',
        'schema_version',
        'created_at',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];
}
