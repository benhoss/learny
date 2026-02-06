<?php

namespace App\Services\Concepts;

use App\Concerns\RetriesLlmCalls;
use Prism\Prism\Enums\Provider;
use Prism\Prism\Facades\Prism;
use RuntimeException;
use Illuminate\Support\Str;

class PrismConceptExtractor implements ConceptExtractorInterface
{
    use RetriesLlmCalls;

    private const MAX_CONCEPTS = 10;

    public function extract(string $text): array
    {
        $source = trim($text);
        if ($source === '') {
            return [];
        }

        if (! config('prism.providers.openrouter.api_key')) {
            throw new RuntimeException('OpenRouter API key is not configured.');
        }

        $model = config('prism.openrouter.text_model', 'google/gemini-3-flash-preview');
        $schema = '{"concepts":[{"key":"string","label":"string","difficulty":0.5}]}';
        $prompt = $this->buildPrompt($source, $schema);

        $response = $this->callWithRetry(function () use ($model, $prompt) {
            return Prism::text()
                ->using(Provider::OpenRouter, $model)
                ->withSystemPrompt('Extract concise educational concepts and return valid JSON only.')
                ->withPrompt($prompt)
                ->withMaxTokens(800)
                ->usingTemperature(0.2)
                ->asText();
        });

        $decoded = json_decode($response->text, true);
        if (! is_array($decoded)) {
            $decoded = $this->extractJson($response->text);
        }
        if (! is_array($decoded)) {
            $decoded = $this->repairJson($response->text, $schema);
        }

        $rawConcepts = $decoded['concepts'] ?? $decoded;
        if (! is_array($rawConcepts)) {
            return [];
        }

        return $this->normalizeConcepts($rawConcepts);
    }

    protected function buildPrompt(string $source, string $schema): string
    {
        $truncated = strlen($source) > 12000 ? substr($source, 0, 12000) : $source;

        return <<<PROMPT
Extract up to 10 key learning concepts from the text.
Rules:
- Return ONLY JSON.
- Keep keys stable and machine-friendly (kebab-case).
- Keep labels short and learner-friendly.
- Difficulty must be a number between 0 and 1.
- Avoid duplicate concepts.

Schema:
{$schema}

Text:
{$truncated}
PROMPT;
    }

    /**
     * @param  array<int, mixed>  $rawConcepts
     * @return array<int, array{key: string, label: string, difficulty: float}>
     */
    protected function normalizeConcepts(array $rawConcepts): array
    {
        $normalized = [];

        foreach ($rawConcepts as $concept) {
            if (! is_array($concept)) {
                continue;
            }

            $candidateKey = trim((string) ($concept['key'] ?? ''));
            $candidateLabel = trim((string) ($concept['label'] ?? ''));
            $key = Str::slug($candidateKey !== '' ? $candidateKey : $candidateLabel);

            if ($key === '') {
                continue;
            }

            $difficulty = 0.5;
            if (is_numeric($concept['difficulty'] ?? null)) {
                $difficulty = (float) $concept['difficulty'];
            }
            $difficulty = max(0.0, min(1.0, $difficulty));

            $normalized[$key] = [
                'key' => $key,
                'label' => $candidateLabel !== '' ? $candidateLabel : Str::title(str_replace('-', ' ', $key)),
                'difficulty' => $difficulty,
            ];

            if (count($normalized) >= self::MAX_CONCEPTS) {
                break;
            }
        }

        return array_values($normalized);
    }
}
