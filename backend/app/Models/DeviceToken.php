<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class DeviceToken extends Model
{
    use HasFactory;

    protected $collection = 'device_tokens';

    protected $fillable = [
        'user_id',
        'child_id',
        'platform',
        'token',
        'locale',
        'timezone',
        'last_seen_at',
        'revoked_at',
    ];

    protected $casts = [
        'last_seen_at' => 'datetime',
        'revoked_at' => 'datetime',
    ];
}
