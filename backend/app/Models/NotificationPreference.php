<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class NotificationPreference extends Model
{
    use HasFactory;

    protected $collection = 'notification_preferences';

    protected $fillable = [
        'user_id',
        'child_id',
        'channels',
        'quiet_hours',
        'timezone',
        'caps',
        'updated_at',
    ];

    protected $casts = [
        'channels' => 'array',
        'quiet_hours' => 'array',
        'caps' => 'array',
    ];
}
