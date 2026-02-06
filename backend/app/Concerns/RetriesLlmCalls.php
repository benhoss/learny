<?php

namespace App\Concerns;

use Prism\Prism\Enums\Provider;
use Prism\Prism\Exceptions\PrismException;
use Prism\Prism\Facades\Prism;
use RuntimeException;

trait RetriesLlmCalls
{
    /**
     * Call function with retry logic for transient errors.
     *
     * @template T
     *
     * @param  callable(): T  $fn
     * @return T
     */
    protected function callWithRetry(callable $fn, int $maxRetries = 3): mixed
    {
        $lastException = null;

        for ($attempt = 1; $attempt <= $maxRetries; $attempt++) {
            try {
                return $fn();
            } catch (PrismException $e) {
                $lastException = $e;
                $message = $e->getMessage();

                // Retry on 500/502/503/504 errors (transient server errors)
                if (preg_match('/\[50[0234]\]/', $message) && $attempt < $maxRetries) {
                    $waitSeconds = min(pow(2, $attempt), 10); // 2, 4, 10 seconds
                    sleep($waitSeconds);

                    continue;
                }

                throw $e;
            }
        }

        throw $lastException ?? new RuntimeException('Retry logic failed unexpectedly.');
    }

    protected function extractJson(string $content): ?array
    {
        if (preg_match('/```json\\s*(\\{.*\\})\\s*```/s', $content, $match) === 1) {
            return json_decode($match[1], true);
        }

        if (preg_match('/```\\s*(\\{.*\\})\\s*```/s', $content, $match) === 1) {
            return json_decode($match[1], true);
        }

        $start = strpos($content, '{');
        $end = strrpos($content, '}');

        if ($start === false || $end === false || $end <= $start) {
            return null;
        }

        $snippet = substr($content, $start, $end - $start + 1);

        return json_decode($snippet, true);
    }

    protected function repairJson(string $content, string $schema): ?array
    {
        $model = config('prism.openrouter.text_model', 'google/gemini-3-flash-preview');
        $prompt = <<<PROMPT
You are given a response that should be JSON but is not valid JSON.
Fix it to match this schema exactly and output JSON only, no markdown:
{$schema}

Input:
{$content}
PROMPT;

        $response = Prism::text()
            ->using(Provider::OpenRouter, $model)
            ->withSystemPrompt('Return only valid JSON. Do not include any other text.')
            ->withPrompt($prompt)
            ->withMaxTokens(1200)
            ->usingTemperature(0.0)
            ->asText();

        $fixed = json_decode($response->text, true);

        if (! is_array($fixed)) {
            $fixed = $this->extractJson($response->text);
        }

        return is_array($fixed) ? $fixed : null;
    }
}
