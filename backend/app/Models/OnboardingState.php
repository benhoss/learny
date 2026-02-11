<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class OnboardingState extends Model
{
    use HasFactory;

    protected $collection = 'onboarding_states';

    protected $fillable = [
        'user_id',
        'role',
        'current_step',
        'checkpoints',
        'completed_steps',
        'completed_events',
        'started_at',
        'completed_at',
        'last_seen_at',
    ];

    protected $casts = [
        'checkpoints' => 'array',
        'completed_steps' => 'array',
        'completed_events' => 'array',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'last_seen_at' => 'datetime',
    ];

    protected $attributes = [
        'checkpoints' => '[]',
        'completed_steps' => '[]',
        'completed_events' => '[]',
    ];
}
