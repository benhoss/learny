<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class LearningPack extends Model
{
    use HasFactory;

    protected $collection = 'learning_packs';

    protected $fillable = [
        'user_id',
        'child_profile_id',
        'document_id',
        'title',
        'summary',
        'status',
        'schema_version',
        'content',
    ];

    protected $casts = [
        'content' => 'array',
    ];

    public function games()
    {
        return $this->hasMany(Game::class, 'learning_pack_id');
    }

    public function childProfile()
    {
        return $this->belongsTo(ChildProfile::class, 'child_profile_id');
    }
}
