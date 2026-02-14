<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class Game extends Model
{
    use HasFactory;

    protected $collection = 'games';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'owner_type',
        'owner_guest_session_id',
        'owner_child_id',
        'learning_pack_id',
        'type',
        'schema_version',
        'payload',
        'status',
    ];

    protected $casts = [
        'payload' => 'array',
    ];

    protected $attributes = [
        'owner_type' => 'child',
        'owner_guest_session_id' => null,
        'owner_child_id' => null,
    ];
}
