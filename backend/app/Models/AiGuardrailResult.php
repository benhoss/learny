<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class AiGuardrailResult extends Model
{
    use HasFactory;

    protected $collection = 'ai_guardrail_results';

    protected $fillable = [
        'run_id',
        'check_name',
        'check_version',
        'result',
        'risk_points',
        'reason_codes',
        'details_json',
        'created_at',
    ];

    protected $casts = [
        'risk_points' => 'integer',
        'reason_codes' => 'array',
        'details_json' => 'array',
        'created_at' => 'datetime',
    ];
}
