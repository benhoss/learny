<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class ChildProfile extends Model
{
    use HasFactory;

    protected $collection = 'child_profiles';

    protected $fillable = [
        'user_id',
        'name',
        'grade_level',
        'birth_year',
        'school_class',
        'preferred_language',
        'gender',
        'gender_self_description',
        'learning_style_preferences',
        'support_needs',
        'confidence_by_subject',
        'notes',
        'streak_days',
        'longest_streak',
        'last_activity_date',
        'total_xp',
        'memory_personalization_enabled',
        'recommendation_why_enabled',
        'recommendation_why_level',
        'last_memory_reset_at',
        'last_memory_reset_scope',
        'linked_devices',
    ];

    protected $hidden = [
        'user_id',
    ];

    protected $casts = [
        'birth_year' => 'integer',
        'streak_days' => 'integer',
        'longest_streak' => 'integer',
        'total_xp' => 'integer',
        'memory_personalization_enabled' => 'boolean',
        'recommendation_why_enabled' => 'boolean',
        'last_memory_reset_at' => 'datetime',
    ];

    protected $attributes = [
        'streak_days' => 0,
        'longest_streak' => 0,
        'last_activity_date' => null,
        'total_xp' => 0,
        'memory_personalization_enabled' => true,
        'recommendation_why_enabled' => true,
        'recommendation_why_level' => 'detailed',
        'last_memory_reset_at' => null,
        'last_memory_reset_scope' => null,
        'linked_devices' => [],
    ];

    protected $appends = [
        'age',
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

    public function schoolAssessments()
    {
        return $this->hasMany(SchoolAssessment::class, 'child_profile_id');
    }

    protected static function booted(): void
    {
        static::deleting(function (ChildProfile $profile) {
            $profile->schoolAssessments()->delete();
        });
    }

    public function setPreferredLanguageAttribute(?string $value): void
    {
        if (is_string($value) && $value !== '') {
            $segments = explode('-', $value, 2);
            $language = strtolower($segments[0]);
            $region = isset($segments[1]) ? strtoupper($segments[1]) : null;
            $value = $region === null ? $language : $language . '-' . $region;
        }

        $this->attributes['preferred_language'] = $value;
    }

    public function setGenderAttribute(?string $value): void
    {
        $this->attributes['gender'] = $value;

        if ($value !== 'self_describe') {
            $this->attributes['gender_self_description'] = null;
        }
    }

    public function getAgeAttribute(): ?int
    {
        $birthYear = $this->birth_year;
        if ($birthYear === null) {
            return null;
        }

        $age = now()->year - (int) $birthYear;

        if ($age < 0 || $age > 25) {
            return null;
        }

        return $age;
    }
}
