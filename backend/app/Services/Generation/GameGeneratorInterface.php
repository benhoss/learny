<?php

namespace App\Services\Generation;

use App\Models\LearningPack;

interface GameGeneratorInterface
{
    /**
     * @return array<string, mixed>
     */
    public function generate(LearningPack $pack, string $type): array;
}
