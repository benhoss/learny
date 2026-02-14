<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class RevisionSession extends Model
{
    use HasFactory;

    protected $collection = 'revision_sessions';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'owner_type',
        'owner_guest_session_id',
        'owner_child_id',
        'source',
        'status',
        'started_at',
        'completed_at',
        'total_items',
        'correct_items',
        'xp_earned',
        'subject_label',
        'duration_minutes',
        'items',
        'results',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'total_items' => 'integer',
        'correct_items' => 'integer',
        'xp_earned' => 'integer',
        'duration_minutes' => 'integer',
        'items' => 'array',
        'results' => 'array',
    ];

    protected $attributes = [
        'owner_type' => 'child',
        'owner_guest_session_id' => null,
        'owner_child_id' => null,
    ];
}
