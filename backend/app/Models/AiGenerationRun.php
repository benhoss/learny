<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class AiGenerationRun extends Model
{
    use HasFactory;

    protected $collection = 'ai_generation_runs';

    protected $fillable = [
        'correlation_id',
        'feature_name',
        'actor_type',
        'actor_ref',
        'child_profile_id',
        'document_id',
        'provider',
        'model_name',
        'model_version',
        'prompt_template_version',
        'started_at',
        'completed_at',
        'final_status',
        'final_risk_score',
        'error_message',
        'metadata',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'final_risk_score' => 'integer',
        'metadata' => 'array',
    ];
}
