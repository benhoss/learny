<?php

namespace App\Services\Concepts;

interface ConceptExtractorInterface
{
    /**
     * @return array<int, array{key: string, label: string, difficulty: float}>
     */
    public function extract(string $text): array;
}
