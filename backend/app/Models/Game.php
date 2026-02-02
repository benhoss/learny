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
        'learning_pack_id',
        'type',
        'schema_version',
        'payload',
        'status',
    ];

    protected $casts = [
        'payload' => 'array',
    ];
}
