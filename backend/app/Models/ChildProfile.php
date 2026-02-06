<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ChildProfile extends Model
{
    use HasFactory;
    protected $collection = 'child_profiles';

    protected $fillable = [
        'user_id',
        'name',
        'grade_level',
        'birth_year',
        'notes',
        'streak_days',
        'longest_streak',
        'last_activity_date',
        'total_xp',
    ];

    protected $casts = [
        'birth_year' => 'integer',
        'streak_days' => 'integer',
        'longest_streak' => 'integer',
        'total_xp' => 'integer',
    ];

    protected $attributes = [
        'streak_days' => 0,
        'longest_streak' => 0,
        'last_activity_date' => null,
        'total_xp' => 0,
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function masteryProfiles()
    {
        return $this->hasMany(MasteryProfile::class, 'child_profile_id');
    }

    public function documents()
    {
        return $this->hasMany(Document::class, 'child_profile_id');
    }

    public function concepts()
    {
        return $this->hasMany(Concept::class, 'child_profile_id');
    }

    public function learningPacks()
    {
        return $this->hasMany(LearningPack::class, 'child_profile_id');
    }
}
