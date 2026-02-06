<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class LearningMemoryEvent extends Model
{
    use HasFactory;

    protected $collection = 'learning_memory_events';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'concept_key',
        'event_type',
        'source_type',
        'source_id',
        'occurred_at',
        'confidence',
        'metadata',
    ];

    protected $casts = [
        'occurred_at' => 'datetime',
        'confidence' => 'float',
        'metadata' => 'array',
    ];
}
