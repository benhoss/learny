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
    ];

    protected $casts = [
        'birth_year' => 'integer',
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
