<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use App\Models\Document;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\LearningMemoryEvent;
use App\Models\LearningPack;
use App\Models\MasteryProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class GameResultController extends Controller
{
    use FindsOwnedChild;

    protected const SUPPORTED_GAME_TYPES = [
        'flashcards',
        'quiz',
        'matching',
        'true_false',
        'fill_blank',
        'ordering',
        'multiple_select',
        'short_answer',
    ];

    public function index(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $validated = $request->validate([
            'limit' => ['nullable', 'integer', 'min:1', 'max:200'],
        ]);
        $limit = (int) ($validated['limit'] ?? 50);

        $results = GameResult::where('child_profile_id', (string) $child->_id)
            ->orderBy('completed_at', 'desc')
            ->limit($limit)
            ->get();

        $packIds = $results->pluck('learning_pack_id')
            ->filter()
            ->map(fn ($id) => (string) $id)
            ->unique()
            ->values()
            ->all();

        $packs = LearningPack::whereIn('_id', $packIds)
            ->get()
            ->keyBy(fn (LearningPack $pack) => (string) $pack->_id);

        $documentIds = $packs->pluck('document_id')
            ->filter()
            ->map(fn ($id) => (string) $id)
            ->unique()
            ->values()
            ->all();

        $documents = Document::whereIn('_id', $documentIds)
            ->get()
            ->keyBy(fn (Document $document) => (string) $document->_id);

        $games = Game::whereIn('learning_pack_id', $packIds)
            ->where('status', 'ready')
            ->get(['learning_pack_id', 'type'])
            ->groupBy(fn (Game $game) => (string) $game->learning_pack_id);

        $itemsAsc = [];
        $previousScoreBySubject = [];
        foreach ($results->reverse()->values() as $result) {
            $pack = $packs->get((string) ($result->learning_pack_id ?? ''));
            $document = $pack
                ? $documents->get((string) ($pack->document_id ?? ''))
                : null;

            $subject = $this->subjectForActivity($pack, $document);
            $totalQuestions = (int) ($result->total_questions ?? 0);
            $correctAnswers = (int) ($result->correct_answers ?? 0);
            $scorePercent = $this->scorePercentForActivity($result, $correctAnswers, $totalQuestions);
            $progressionDelta = array_key_exists($subject, $previousScoreBySubject)
                ? $scorePercent - $previousScoreBySubject[$subject]
                : null;
            $previousScoreBySubject[$subject] = $scorePercent;

            $packGameTypes = collect($games->get((string) ($result->learning_pack_id ?? ''), collect()))
                ->pluck('type')
                ->filter()
                ->map(fn ($type) => (string) $type)
                ->unique()
                ->values()
                ->all();

            $itemsAsc[] = [
                'id' => $this->stringifyId($result->_id ?? null),
                'completed_at' => $result->completed_at,
                'game_type' => (string) ($result->game_type ?? ''),
                'pack_id' => $pack ? $this->stringifyId($pack->_id) : null,
                'pack_title' => $pack?->title,
                'document_id' => $document ? $this->stringifyId($document->_id) : null,
                'document_title' => $document?->original_filename,
                'subject' => $subject,
                'score_percent' => $scorePercent,
                'correct_answers' => $correctAnswers,
                'total_questions' => $totalQuestions,
                'xp_earned' => (int) ($result->xp_earned ?? 0),
                'progression_delta' => $progressionDelta,
                'cheer_message' => $this->cheerMessageForActivity($scorePercent, $progressionDelta),
                'available_game_types' => $packGameTypes,
                'remaining_game_types' => array_values(array_diff(self::SUPPORTED_GAME_TYPES, $packGameTypes)),
            ];
        }

        return response()->json([
            'data' => array_reverse($itemsAsc),
        ]);
    }

    public function store(Request $request, string $childId, string $packId, string $gameId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $game = Game::where('_id', $gameId)
            ->where('learning_pack_id', $packId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        $data = $request->validate([
            'results' => ['required', 'array', 'min:1', 'max:100'],
            'results.*.correct' => ['required', 'boolean'],
            'results.*.prompt' => ['nullable', 'string', 'max:500'],
            'results.*.topic' => ['nullable', 'string', 'max:255'],
            'results.*.response' => ['nullable', 'string', 'max:500'],
            'results.*.expected' => ['nullable', 'string', 'max:500'],
            'score' => ['nullable', 'numeric', 'min:0', 'max:1'],
            'total_questions' => ['nullable', 'integer', 'min:0'],
            'correct_answers' => ['nullable', 'integer', 'min:0'],
            'language' => ['nullable', 'string'],
            'metadata' => ['nullable', 'array', 'max:20'],
            'completed_at' => ['nullable', 'date', 'before_or_equal:now'],
        ]);

        // Strip invalid topic values that don't match the learning pack concepts.
        $pack = LearningPack::where('_id', $packId)->first();
        $validTopics = collect($pack?->content['concepts'] ?? [])
            ->map(fn ($c) => $c['key'] ?? $c['concept_key'] ?? '')
            ->filter()
            ->values()
            ->all();

        if ($validTopics) {
            foreach ($data['results'] as $i => $r) {
                if (! empty($r['topic']) && ! in_array($r['topic'], $validTopics, true)) {
                    $data['results'][$i]['topic'] = null;
                }
            }
        }

        $results = $data['results'];
        $total = $data['total_questions'] ?? count($results);
        $correct = $data['correct_answers'] ?? collect($results)
            ->where('correct', true)
            ->count();
        $score = $data['score'] ?? ($total > 0 ? $correct / $total : 0.0);

        $xpEarned = $correct * 10;

        $record = GameResult::firstOrCreate([
            'child_profile_id' => (string) $child->_id,
            'game_id' => (string) $game->_id,
        ], [
            'user_id' => (string) Auth::guard('api')->id(),
            'learning_pack_id' => (string) $packId,
            'game_type' => $game->type,
            'schema_version' => $game->schema_version,
            'game_payload' => $game->payload,
            'results' => $results,
            'score' => $score,
            'total_questions' => $total,
            'correct_answers' => $correct,
            'xp_earned' => $xpEarned,
            'language' => $data['language'] ?? null,
            'metadata' => $data['metadata'] ?? [],
            'completed_at' => isset($data['completed_at']) ? $data['completed_at'] : now(),
        ]);

        if ($record->wasRecentlyCreated) {
            $this->updateMastery($child, $results);
            $streakData = $this->updateStreak($child, $xpEarned);
            $this->recordLearningMemoryEvents($child, $game, $record, $results);
        } else {
            $freshChild = ChildProfile::where('_id', (string) $child->_id)->first();
            $streakData = [
                'streak_days' => $freshChild?->streak_days ?? 0,
                'total_xp' => $freshChild?->total_xp ?? 0,
            ];
        }
        $recordXp = $record->xp_earned ?? ($record->correct_answers ?? 0) * 10;

        return response()->json([
            'data' => $record,
            'xp_earned' => $recordXp,
            'total_xp' => $streakData['total_xp'],
            'streak_days' => $streakData['streak_days'],
            'idempotent_replay' => ! $record->wasRecentlyCreated,
        ], 201);
    }

    protected function updateMastery(ChildProfile $child, array $results): void
    {
        $childId = (string) $child->_id;

        // Group results by topic to batch updates per concept
        $grouped = [];
        foreach ($results as $result) {
            $topic = $result['topic'] ?? null;
            if (! $topic) {
                continue;
            }
            $grouped[$topic][] = $result;
        }

        foreach ($grouped as $conceptKey => $questionResults) {
            $correctCount = collect($questionResults)->where('correct', true)->count();
            $totalCount = count($questionResults);
            $allCorrect = $correctCount === $totalCount;

            $mastery = MasteryProfile::firstOrCreate(
                ['child_profile_id' => $childId, 'concept_key' => $conceptKey],
                ['concept_label' => $conceptKey, 'mastery_level' => 0.0, 'total_attempts' => 0, 'correct_attempts' => 0, 'consecutive_correct' => 0]
            );

            // Compute new values in memory, single save
            $mastery->total_attempts += $totalCount;
            $mastery->correct_attempts += $correctCount;
            $mastery->mastery_level = $mastery->total_attempts > 0
                ? $mastery->correct_attempts / $mastery->total_attempts
                : 0.0;
            $mastery->last_attempt_at = now();
            $mastery->consecutive_correct = $allCorrect
                ? ($mastery->consecutive_correct ?? 0) + 1
                : 0;

            // Naive SRS intervals: wrong=1d, right=3d, right 2x in a row=7d
            if (! $allCorrect) {
                $mastery->next_review_at = now()->addDay();
            } elseif ($mastery->consecutive_correct >= 2) {
                $mastery->next_review_at = now()->addDays(7);
            } else {
                $mastery->next_review_at = now()->addDays(3);
            }

            $mastery->save();
        }
    }

    protected function updateStreak(ChildProfile $child, int $xpEarned): array
    {
        $today = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();
        $childId = (string) $child->_id;

        $child->refresh();
        $lastActivity = $child->last_activity_date;

        if ($lastActivity !== $today) {
            $updated = 0;

            if ($lastActivity === $yesterday) {
                // Atomic compare-and-set to avoid duplicate increments.
                $updated = ChildProfile::where('_id', $childId)
                    ->where('last_activity_date', $yesterday)
                    ->increment('streak_days', 1, ['last_activity_date' => $today]);
            } else {
                // Reset to day 1 if last activity is missing or older than yesterday.
                $updated = ChildProfile::where('_id', $childId)
                    ->where(function ($query) use ($today, $yesterday) {
                        $query->whereNull('last_activity_date')
                            ->orWhere(function ($subQuery) use ($today, $yesterday) {
                                $subQuery->whereNotIn('last_activity_date', [$today, $yesterday]);
                            });
                    })
                    ->update([
                        'streak_days' => 1,
                        'last_activity_date' => $today,
                    ]);
            }

            $child->refresh();

            if ($updated > 0) {
                $nextLongest = max($child->longest_streak ?? 0, $child->streak_days ?? 0);
                ChildProfile::where('_id', $childId)
                    ->where(function ($query) use ($nextLongest) {
                        $query->whereNull('longest_streak')
                            ->orWhere('longest_streak', '<', $nextLongest);
                    })
                    ->update(['longest_streak' => $nextLongest]);
                $child->refresh();
            }
        }

        $child->increment('total_xp', $xpEarned);
        $child->refresh();

        return [
            'streak_days' => $child->streak_days ?? 0,
            'total_xp' => $child->total_xp ?? 0,
        ];
    }

    protected function recordLearningMemoryEvents(
        ChildProfile $child,
        Game $game,
        GameResult $record,
        array $results
    ): void {
        $childId = (string) $child->_id;
        $sourceId = (string) $record->_id;
        $userId = (string) Auth::guard('api')->id();
        $baseOrder = $this->nextEventOrder($childId);

        foreach ($results as $index => $result) {
            $conceptKey = trim((string) ($result['topic'] ?? ''));
            if ($conceptKey === '') {
                continue;
            }

            $isCorrect = (bool) ($result['correct'] ?? false);
            $eventKey = sha1('game_result:'.$sourceId.':'.$conceptKey.':'.$index);

            LearningMemoryEvent::updateOrCreate([
                'event_key' => $eventKey,
            ], [
                'user_id' => $userId,
                'child_profile_id' => $childId,
                'concept_key' => $conceptKey,
                'event_type' => 'play',
                'event_key' => $eventKey,
                'event_order' => $baseOrder + $index,
                'source_type' => 'game_result',
                'source_id' => $sourceId,
                'occurred_at' => $record->completed_at ?? now(),
                'confidence' => $isCorrect ? 1.0 : 0.3,
                'metadata' => [
                    'game_id' => (string) $game->_id,
                    'game_type' => (string) $game->type,
                    'prompt' => (string) ($result['prompt'] ?? ''),
                    'response' => (string) ($result['response'] ?? ''),
                    'expected' => (string) ($result['expected'] ?? ''),
                    'correct' => $isCorrect,
                ],
            ]);
        }
    }

    protected function nextEventOrder(string $childId): int
    {
        $maxOrder = LearningMemoryEvent::where('child_profile_id', $childId)->max('event_order');

        return is_numeric($maxOrder) ? ((int) $maxOrder + 1) : 1;
    }

    protected function stringifyId(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }

        if (is_array($value)) {
            $oid = $value['$oid'] ?? $value['oid'] ?? null;

            return $oid ? (string) $oid : null;
        }

        return (string) $value;
    }

    protected function subjectForActivity(?LearningPack $pack, ?Document $document): string
    {
        if (! empty($document?->subject)) {
            return (string) $document->subject;
        }

        if (! empty($pack?->summary)) {
            $first = explode(' ', trim((string) $pack->summary))[0] ?? '';
            if ($first !== '') {
                return $first;
            }
        }

        if (! empty($pack?->title)) {
            return (string) $pack->title;
        }

        return 'General';
    }

    protected function scorePercentForActivity(
        GameResult $result,
        int $correctAnswers,
        int $totalQuestions
    ): int {
        if ($totalQuestions > 0) {
            return (int) round(($correctAnswers / $totalQuestions) * 100);
        }

        return (int) round(((float) ($result->score ?? 0.0)) * 100);
    }

    protected function cheerMessageForActivity(int $scorePercent, ?int $progressionDelta): string
    {
        if ($scorePercent >= 90 && ($progressionDelta ?? 0) >= 5) {
            return 'Amazing jump. Your consistency is paying off.';
        }
        if ($scorePercent >= 90) {
            return 'Excellent focus. Keep this rhythm going.';
        }
        if (($progressionDelta ?? 0) > 0) {
            return 'Nice improvement from your last attempt.';
        }
        if ($scorePercent >= 70) {
            return 'Solid progress. You are building mastery.';
        }
        if ($scorePercent >= 50) {
            return 'You are building momentum. One more run can lift this.';
        }

        return 'Every attempt strengthens memory. Try again while it is fresh.';
    }

}
