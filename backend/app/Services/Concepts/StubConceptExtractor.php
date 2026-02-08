<?php

namespace App\Services\Concepts;

use Illuminate\Support\Str;

class StubConceptExtractor implements ConceptExtractorInterface
{
    public function extract(string $text, ?string $language = null): array
    {
        $tokens = preg_split('/\s+/', strtolower(strip_tags($text)));
        $tokens = array_filter($tokens, fn ($token) => $token !== '');
        $unique = array_values(array_unique($tokens));

        $concepts = [];
        foreach (array_slice($unique, 0, 5) as $token) {
            $concepts[] = [
                'key' => Str::slug($token),
                'label' => ucfirst($token),
                'difficulty' => 0.5,
            ];
        }

        return $concepts;
    }
}
