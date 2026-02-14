<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class GuestSession extends Model
{
    use HasFactory;

    protected $collection = 'guest_sessions';

    protected $fillable = [
        'session_id',
        'device_signature_hash',
        'state',
        'first_seen_at',
        'last_seen_at',
        'guest_user_id',
        'guest_child_id',
        'linked_user_id',
        'linked_child_id',
        'linked_at',
        'migration_summary',
    ];

    protected $casts = [
        'first_seen_at' => 'datetime',
        'last_seen_at' => 'datetime',
        'linked_at' => 'datetime',
        'migration_summary' => 'array',
    ];

    protected $attributes = [
        'state' => 'guest_prelink',
        'guest_user_id' => null,
        'guest_child_id' => null,
        'linked_user_id' => null,
        'linked_child_id' => null,
        'linked_at' => null,
        'migration_summary' => '[]',
    ];
}
