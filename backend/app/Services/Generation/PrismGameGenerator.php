<?php

namespace App\Services\Generation;

use App\Models\Game;
use App\Models\LearningPack;
use Prism\Prism\Enums\Provider;
use Prism\Prism\Facades\Prism;
use RuntimeException;

class PrismGameGenerator implements GameGeneratorInterface
{
    private const RECENT_GAMES_LIMIT = 5;

    public function generate(LearningPack $pack, string $type): array
    {
        $model = config('prism.openrouter.text_model', 'google/gemini-3-flash-preview');

        if (! config('prism.providers.openrouter.api_key')) {
            throw new RuntimeException('OpenRouter API key is not configured.');
        }

        $schema = match ($type) {
            'flashcards' => '{"title":"string","intro":"string","cards":[{"front":"string","back":"string","hint":"string","topic":"string","difficulty":0.5}]}',
            'quiz' => '{"title":"string","intro":"string","questions":[{"prompt":"string","choices":["string"],"answer_index":0,"hint":"string","explanation":"string","topic":"string","difficulty":0.5}]}',
            'matching' => '{"title":"string","intro":"string","pairs":[{"left":"string","right":"string","explanation":"string","topic":"string","difficulty":0.5}]}',
            'true_false' => '{"title":"string","intro":"string","questions":[{"statement":"string","answer":true,"explanation":"string","topic":"string","difficulty":0.5}]}',
            'fill_blank' => '{"title":"string","intro":"string","questions":[{"prompt":"string","answer":"string","hint":"string","explanation":"string","topic":"string","difficulty":0.5}]}',
            'ordering' => '{"title":"string","intro":"string","items":[{"prompt":"string","sequence":["string"]}]}',
            'multiple_select' => '{"title":"string","intro":"string","questions":[{"prompt":"string","choices":["string"],"answer_indices":[0],"hint":"string","explanation":"string","topic":"string","difficulty":0.5}]}',
            'short_answer' => '{"title":"string","intro":"string","questions":[{"prompt":"string","answer":"string","accepted_answers":["string"],"hint":"string","explanation":"string","topic":"string","difficulty":0.5}]}',
            default => '{}',
        };

        $recentGames = $this->recentGameHistory((string) $pack->user_id, (string) $pack->_id);
        $prompt = $this->buildPrompt($pack, $type, $schema, $recentGames);

        $response = Prism::text()
            ->using(Provider::OpenRouter, $model)
            ->withSystemPrompt('You generate concise, valid JSON only.')
            ->withPrompt($prompt)
            ->withMaxTokens(1000)
            ->usingTemperature(0.3)
            ->asText();

        $decoded = json_decode($response->text, true);

        if (! is_array($decoded)) {
            $decoded = $this->extractJson($response->text);
        }

        if (! is_array($decoded)) {
            $decoded = $this->repairJson($response->text, $schema);
        }

        if (! is_array($decoded)) {
            throw new RuntimeException('Game generation failed: invalid JSON.');
        }

        return $decoded;
    }

    protected function buildPrompt(
        LearningPack $pack,
        string $type,
        string $schema,
        string $recentGames
    ): string
    {
        $concepts = $pack->content['concepts'] ?? [];
        $conceptText = json_encode($concepts);
        $objective = $pack->content['objective'] ?? '';

        return <<<PROMPT
Create a {$type} game payload for a child aged 10-14.
Use the same language as the learning pack content for every prompt and choice.
Do not use English unless the learning pack is English.
Return JSON matching this schema:
{$schema}

Concepts: {$conceptText}
Objective: {$objective}
Recent games (avoid repeating questions/patterns and vary style/difficulty):
{$recentGames}

Return JSON only.
PROMPT;
    }

    protected function recentGameHistory(string $userId, string $currentPackId): string
    {
        if ($userId === '') {
            return 'None.';
        }

        $games = Game::where('user_id', $userId)
            ->where('learning_pack_id', '!=', $currentPackId)
            ->orderBy('created_at', 'desc')
            ->limit(self::RECENT_GAMES_LIMIT)
            ->get();

        if ($games->isEmpty()) {
            return 'None.';
        }

        $summaries = [];
        foreach ($games as $game) {
            $type = $game->type ?? 'unknown';
            $payload = $game->payload ?? [];
            $sample = '';
            if ($type === 'quiz') {
                $questions = $payload['questions'] ?? [];
                $sample = isset($questions[0]['prompt']) ? (string) $questions[0]['prompt'] : '';
            } elseif ($type === 'true_false') {
                $questions = $payload['questions'] ?? [];
                $sample = isset($questions[0]['statement']) ? (string) $questions[0]['statement'] : '';
            } elseif ($type === 'fill_blank' || $type === 'short_answer') {
                $questions = $payload['questions'] ?? [];
                $sample = isset($questions[0]['prompt']) ? (string) $questions[0]['prompt'] : '';
            } elseif ($type === 'matching') {
                $pairs = $payload['pairs'] ?? [];
                if (isset($pairs[0]['left'], $pairs[0]['right'])) {
                    $sample = (string) ($pairs[0]['left'].' ↔ '.$pairs[0]['right']);
                }
            } elseif ($type === 'ordering') {
                $items = $payload['items'] ?? [];
                $sample = isset($items[0]['prompt']) ? (string) $items[0]['prompt'] : '';
            }
            $summaries[] = trim("{$type}: {$sample}");
        }

        return implode("\n", array_filter($summaries));
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
            ->using(Provider::Mistral, $model)
            ->withSystemPrompt('Return only valid JSON. Do not include any other text.')
            ->withPrompt($prompt)
            ->withMaxTokens(800)
            ->usingTemperature(0.0)
            ->asText();

        $fixed = json_decode($response->text, true);

        if (! is_array($fixed)) {
            $fixed = $this->extractJson($response->text);
        }

        return is_array($fixed) ? $fixed : null;
    }
}
