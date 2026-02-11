<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class OnboardingLinkToken extends Model
{
    use HasFactory;

    protected $collection = 'onboarding_link_tokens';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'code_hash',
        'expires_at',
        'consumed_at',
        'consumed_device_id',
        'failed_attempts',
        'locked_at',
        'metadata',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'consumed_at' => 'datetime',
        'locked_at' => 'datetime',
        'failed_attempts' => 'integer',
        'metadata' => 'array',
    ];

    protected $attributes = [
        'failed_attempts' => 0,
        'locked_at' => null,
    ];
}
