<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\LearningMemoryEvent;
use App\Models\MasteryProfile;
use App\Models\RevisionSession;
use App\Models\GuestSession;
use App\Services\Revision\RevisionComposer;
use App\Services\Translator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RevisionSessionController extends Controller
{
    use FindsOwnedChild;

    public function start(Request $request, string $childId, RevisionComposer $composer): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $limit = max(3, min(10, (int) $request->integer('limit', 5)));
        $guestSession = GuestSession::where('guest_user_id', (string) Auth::guard('api')->id())
            ->where('guest_child_id', (string) $child->_id)
            ->first();

        $items = $composer->compose($child, $limit);

        $session = RevisionSession::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'owner_type' => $guestSession ? 'guest' : 'child',
            'owner_child_id' => (string) $child->_id,
            'owner_guest_session_id' => $guestSession?->session_id,
            'source' => 'mixed',
            'status' => 'active',
            'started_at' => now(),
            'total_items' => count($items),
            'correct_items' => 0,
            'xp_earned' => 0,
            'subject_label' => Translator::forChild($child)->get('revision.subject_label'),
            'duration_minutes' => 5,
            'items' => $items,
            'results' => [],
        ]);

        return response()->json([
            'data' => $this->formatSession($session),
            'idempotent_replay' => false,
        ]);
    }

    public function submit(Request $request, string $childId, string $sessionId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);

        $session = RevisionSession::where('_id', $sessionId)
            ->where('child_profile_id', (string) $child->_id)
            ->firstOrFail();

        if (($session->status ?? '') === 'completed') {
            return response()->json([
                'data' => $this->formatSession($session),
                'idempotent_replay' => true,
            ]);
        }

        $payload = $request->validate([
            'results' => ['required', 'array', 'min:1', 'max:100'],
            'results.*.item_id' => ['required', 'string'],
            'results.*.selected_index' => ['required', 'integer', 'min:0', 'max:10'],
            'results.*.latency_ms' => ['nullable', 'integer', 'min:0', 'max:300000'],
        ]);

        $itemById = collect($session->items ?? [])->keyBy('id');
        $scored = [];
        $correctCount = 0;
        $baseOrder = $this->nextEventOrder((string) $child->_id);

        foreach ($payload['results'] as $index => $result) {
            $item = $itemById->get($result['item_id']);
            if (! is_array($item)) {
                continue;
            }

            $selectedIndex = (int) $result['selected_index'];
            $isCorrect = $selectedIndex === (int) ($item['correct_index'] ?? -1);

            if ($isCorrect) {
                $correctCount += 1;
            }

            $scored[] = [
                'item_id' => (string) $result['item_id'],
                'selected_index' => $selectedIndex,
                'correct' => $isCorrect,
                'latency_ms' => (int) ($result['latency_ms'] ?? 0),
                'concept_key' => (string) ($item['concept_key'] ?? ''),
                'source' => (string) ($item['source'] ?? ''),
            ];

            $this->recordLearningMemoryEvent(
                (string) $child->_id,
                $sessionId,
                $item,
                $isCorrect,
                $result,
                $baseOrder + $index
            );
            $this->updateMasteryFromRevision((string) $child->_id, $item, $isCorrect);
        }

        $totalItems = count($scored);
        $xpEarned = $correctCount * 3;

        $session->status = 'completed';
        $session->completed_at = now();
        $session->total_items = $totalItems;
        $session->correct_items = $correctCount;
        $session->xp_earned = $xpEarned;
        $session->results = $scored;
        $session->save();

        return response()->json([
            'data' => $this->formatSession($session),
            'idempotent_replay' => false,
        ]);
    }

    protected function recordLearningMemoryEvent(
        string $childId,
        string $sessionId,
        array $item,
        bool $isCorrect,
        array $result,
        int $eventOrder
    ): void {
        $conceptKey = (string) ($item['concept_key'] ?? '');
        if ($conceptKey === '') {
            return;
        }
        $itemId = (string) ($item['id'] ?? '');
        $eventKey = sha1('revision_session:'.$sessionId.':'.$conceptKey.':'.$itemId);

        LearningMemoryEvent::updateOrCreate([
            'event_key' => $eventKey,
        ], [
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => $childId,
            'concept_key' => $conceptKey,
            'event_type' => 'review',
            'event_key' => $eventKey,
            'event_order' => $eventOrder,
            'source_type' => 'revision_session',
            'source_id' => $sessionId,
            'occurred_at' => now(),
            'confidence' => $isCorrect ? 1.0 : 0.3,
            'metadata' => [
                'prompt' => (string) ($item['prompt'] ?? ''),
                'source' => (string) ($item['source'] ?? ''),
                'selected_index' => (int) ($result['selected_index'] ?? 0),
                'latency_ms' => (int) ($result['latency_ms'] ?? 0),
                'correct' => $isCorrect,
            ],
        ]);
    }

    protected function updateMasteryFromRevision(string $childId, array $item, bool $isCorrect): void
    {
        $conceptKey = (string) ($item['concept_key'] ?? '');
        if ($conceptKey === '') {
            return;
        }

        $conceptLabel = (string) ($item['concept_label'] ?? $conceptKey);

        $mastery = MasteryProfile::firstOrCreate(
            [
                'child_profile_id' => $childId,
                'concept_key' => $conceptKey,
            ],
            [
                'concept_label' => $conceptLabel,
                'mastery_level' => 0.0,
                'total_attempts' => 0,
                'correct_attempts' => 0,
                'consecutive_correct' => 0,
            ]
        );

        $mastery->total_attempts = (int) ($mastery->total_attempts ?? 0) + 1;
        $mastery->correct_attempts = (int) ($mastery->correct_attempts ?? 0) + ($isCorrect ? 1 : 0);
        $mastery->mastery_level = $mastery->total_attempts > 0
            ? $mastery->correct_attempts / $mastery->total_attempts
            : 0.0;
        $mastery->last_attempt_at = now();
        $mastery->consecutive_correct = $isCorrect
            ? ((int) ($mastery->consecutive_correct ?? 0) + 1)
            : 0;
        $mastery->next_review_at = ! $isCorrect
            ? now()->addDay()
            : ((int) $mastery->consecutive_correct >= 2 ? now()->addDays(7) : now()->addDays(3));

        $mastery->save();
    }

    protected function formatSession(RevisionSession $session): array
    {
        return [
            'id' => (string) $session->_id,
            'status' => (string) ($session->status ?? 'active'),
            'source' => (string) ($session->source ?? 'mixed'),
            'subject_label' => (string) ($session->subject_label ?? 'Quick Revision'),
            'duration_minutes' => (int) ($session->duration_minutes ?? 5),
            'total_items' => (int) ($session->total_items ?? 0),
            'correct_items' => (int) ($session->correct_items ?? 0),
            'xp_earned' => (int) ($session->xp_earned ?? 0),
            'started_at' => optional($session->started_at)->toISOString(),
            'completed_at' => optional($session->completed_at)->toISOString(),
            'items' => array_values($session->items ?? []),
            'results' => array_values($session->results ?? []),
        ];
    }

    protected function nextEventOrder(string $childId): int
    {
        $maxOrder = LearningMemoryEvent::where('child_profile_id', $childId)->max('event_order');

        return is_numeric($maxOrder) ? ((int) $maxOrder + 1) : 1;
    }
}
