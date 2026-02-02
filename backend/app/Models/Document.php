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
        'original_filename',
        'storage_disk',
        'storage_path',
        'mime_type',
        'size_bytes',
        'extracted_text',
        'ocr_error',
        'processed_at',
        'subject',
        'language',
        'grade_level',
        'learning_goal',
        'context_text',
    ];

    protected $casts = [
        'size_bytes' => 'integer',
        'processed_at' => 'datetime',
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
