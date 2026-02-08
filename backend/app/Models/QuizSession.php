<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class QuizSession extends Model
{
    use HasFactory;

    protected $collection = 'quiz_sessions';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'learning_pack_id',
        'game_id',
        'status',
        'requested_question_count',
        'available_question_count',
        'question_indices',
        'current_index',
        'correct_count',
        'results',
        'started_at',
        'last_interaction_at',
        'paused_at',
        'completed_at',
    ];

    protected $casts = [
        'requested_question_count' => 'integer',
        'available_question_count' => 'integer',
        'question_indices' => 'array',
        'current_index' => 'integer',
        'correct_count' => 'integer',
        'results' => 'array',
        'started_at' => 'datetime',
        'last_interaction_at' => 'datetime',
        'paused_at' => 'datetime',
        'completed_at' => 'datetime',
    ];
}
