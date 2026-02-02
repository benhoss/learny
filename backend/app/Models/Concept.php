<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class Concept extends Model
{
    use HasFactory;

    protected $collection = 'concepts';

    protected $fillable = [
        'child_profile_id',
        'document_id',
        'concept_key',
        'concept_label',
        'difficulty',
    ];

    protected $casts = [
        'difficulty' => 'float',
    ];
}
