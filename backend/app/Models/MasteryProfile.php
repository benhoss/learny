<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class MasteryProfile extends Model
{
    use HasFactory;
    protected $collection = 'mastery_profiles';

    protected $fillable = [
        'child_profile_id',
        'concept_key',
        'concept_label',
        'mastery_level',
        'total_attempts',
        'correct_attempts',
        'last_attempt_at',
    ];

    protected $casts = [
        'mastery_level' => 'float',
        'total_attempts' => 'integer',
        'correct_attempts' => 'integer',
        'last_attempt_at' => 'datetime',
    ];

    public function childProfile()
    {
        return $this->belongsTo(ChildProfile::class, 'child_profile_id');
    }
}
