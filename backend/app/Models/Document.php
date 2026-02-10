<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Document extends Model
{
    use HasFactory;
    protected $collection = 'documents';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'status',
        'title',
        'original_filename',
        'storage_disk',
        'storage_path',
        'storage_paths',
        'mime_type',
        'mime_types',
        'size_bytes',
        'extracted_text',
        'ocr_error',
        'processed_at',
        'subject',
        'language',
        'grade_level',
        'learning_goal',
        'context_text',
        'requested_game_types',
        'scan_status',
        'scan_topic_suggestion',
        'scan_language_suggestion',
        'scan_confidence',
        'scan_alternatives',
        'scan_model',
        'scan_completed_at',
        'validation_status',
        'validated_topic',
        'validated_language',
        'validated_at',
        'pipeline_stage',
        'stage_started_at',
        'stage_completed_at',
        'progress_hint',
        'first_playable_at',
        'first_playable_game_type',
        'ready_game_types',
        'stage_timings',
        'stage_history',
    ];

    protected $casts = [
        'size_bytes' => 'integer',
        'processed_at' => 'datetime',
        'storage_paths' => 'array',
        'mime_types' => 'array',
        'requested_game_types' => 'array',
        'scan_confidence' => 'float',
        'scan_alternatives' => 'array',
        'scan_completed_at' => 'datetime',
        'validated_at' => 'datetime',
        'stage_started_at' => 'datetime',
        'stage_completed_at' => 'datetime',
        'progress_hint' => 'integer',
        'first_playable_at' => 'datetime',
        'ready_game_types' => 'array',
        'stage_timings' => 'array',
        'stage_history' => 'array',
    ];

    public function childProfile()
    {
        return $this->belongsTo(ChildProfile::class, 'child_profile_id');
    }

    public function concepts()
    {
        return $this->hasMany(Concept::class, 'document_id');
    }
}
