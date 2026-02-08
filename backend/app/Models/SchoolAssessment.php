<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class SchoolAssessment extends Model
{
    use HasFactory;

    protected $collection = 'school_assessments';

    protected $fillable = [
        'child_profile_id',
        'subject',
        'assessment_type',
        'score',
        'max_score',
        'grade',
        'assessed_at',
        'teacher_note',
        'source',
    ];

    protected $casts = [
        'score' => 'float',
        'max_score' => 'float',
        'assessed_at' => 'datetime',
    ];

    protected $attributes = [
        'source' => 'manual',
    ];

    protected $appends = [
        'score_percent',
    ];

    public function childProfile()
    {
        return $this->belongsTo(ChildProfile::class, 'child_profile_id');
    }

    public function getScorePercentAttribute(): ?float
    {
        $score = $this->score;
        $maxScore = $this->max_score;

        if ($score === null || $maxScore === null || $maxScore <= 0) {
            return null;
        }

        return round(((float) $score / (float) $maxScore) * 100, 2);
    }
}
