<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class OnboardingEvent extends Model
{
    use HasFactory;

    protected $collection = 'onboarding_events';

    protected $fillable = [
        'user_id',
        'role',
        'event_name',
        'step',
        'event_key',
        'guest_session_id',
        'occurred_at',
        'metadata',
    ];

    protected $casts = [
        'occurred_at' => 'datetime',
        'metadata' => 'array',
    ];
}
