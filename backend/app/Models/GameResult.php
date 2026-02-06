<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class GameResult extends Model
{
    use HasFactory;

    protected $collection = 'game_results';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'learning_pack_id',
        'game_id',
        'game_type',
        'schema_version',
        'game_payload',
        'results',
        'score',
        'total_questions',
        'correct_answers',
        'xp_earned',
        'language',
        'metadata',
        'completed_at',
    ];

    protected $casts = [
        'game_payload' => 'array',
        'results' => 'array',
        'score' => 'float',
        'total_questions' => 'integer',
        'correct_answers' => 'integer',
        'xp_earned' => 'integer',
        'metadata' => 'array',
        'completed_at' => 'datetime',
    ];
}
