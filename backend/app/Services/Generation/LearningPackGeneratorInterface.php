<?php

namespace App\Services\Generation;

use App\Models\Document;

interface LearningPackGeneratorInterface
{
    /**
     * @return array<string, mixed>
     */
    public function generate(Document $document, array $concepts): array;
}
