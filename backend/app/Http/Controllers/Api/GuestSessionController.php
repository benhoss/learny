<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\Document;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\GuestSession;
use App\Models\LearningPack;
use App\Models\OnboardingEvent;
use App\Models\QuizSession;
use App\Models\RevisionSession;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class GuestSessionController extends Controller
{
    use FindsOwnedChild;

    public function create(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'device_signature' => ['required', 'string', 'min:8', 'max:200'],
            'instance_id' => ['nullable', 'string', 'max:100'],
        ]);

        $hash = hash('sha256', $payload['device_signature'].'|'.config('app.key'));
        $session = GuestSession::where('device_signature_hash', $hash)->first();

        if (! $session) {
            [$guestUser, $guestChild] = $this->createGuestIdentity();
            $session = GuestSession::create([
                'session_id' => 'guest_'.Str::lower(Str::random(20)),
                'device_signature_hash' => $hash,
                'state' => 'guest_prelink',
                'first_seen_at' => now(),
                'last_seen_at' => now(),
                'guest_user_id' => (string) $guestUser->_id,
                'guest_child_id' => (string) $guestChild->_id,
            ]);
            $this->recordGuestEvent(
                sessionId: (string) $session->session_id,
                eventName: 'guest_session_started',
                step: 'guest_prelink',
                instanceId: $payload['instance_id'] ?? null,
            );
        } else {
            $session->last_seen_at = now();
            $session->save();
        }

        $guestUser = User::where('_id', (string) $session->guest_user_id)->firstOrFail();
        $token = Auth::guard('api')->login($guestUser);

        return response()->json([
            'data' => [
                'guest_session_id' => (string) $session->session_id,
                'state' => (string) ($session->state ?? 'guest_prelink'),
                'guest_child_id' => (string) ($session->guest_child_id ?? ''),
                'access_token' => $token,
                'token_type' => 'bearer',
                'expires_in' => Auth::guard('api')->factory()->getTTL() * 60,
                'linked_at' => optional($session->linked_at)->toIso8601String(),
            ],
        ], 201);
    }

    public function linkAccount(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'guest_session_id' => ['required', 'string', 'max:60'],
            'child_id' => ['required', 'string'],
            'instance_id' => ['nullable', 'string', 'max:100'],
        ]);

        $child = $this->findOwnedChild($payload['child_id']);
        $session = GuestSession::where('session_id', $payload['guest_session_id'])->firstOrFail();
        $userId = (string) Auth::guard('api')->id();
        $childId = (string) $child->_id;

        return Cache::lock('guest:link-account:'.$session->session_id, 10)->block(
            5,
            function () use ($session, $payload, $userId, $childId): JsonResponse {
                $session->refresh();

                if ($session->linked_at !== null) {
                    if ((string) $session->linked_child_id !== $childId) {
                        return response()->json([
                            'message' => 'Guest session already linked to a different child.',
                        ], 409);
                    }

                    return response()->json([
                        'data' => [
                            'guest_session_id' => (string) $session->session_id,
                            'child_id' => $childId,
                            'linked' => true,
                            'idempotent_replay' => true,
                            'migration_summary' => is_array($session->migration_summary) ? $session->migration_summary : [],
                        ],
                    ]);
                }

                $summary = $this->migrateOwnership(
                    guestSessionId: (string) $session->session_id,
                    userId: $userId,
                    childId: $childId,
                );

                $session->state = 'linked';
                $session->linked_user_id = $userId;
                $session->linked_child_id = $childId;
                $session->linked_at = now();
                $session->last_seen_at = now();
                $session->migration_summary = $summary;
                $session->save();

                $this->recordGuestEvent(
                    sessionId: (string) $session->session_id,
                    eventName: 'guest_session_linked',
                    step: 'parent_link_prompt',
                    instanceId: $payload['instance_id'] ?? null,
                    metadata: [
                        'child_id' => $childId,
                        'migration_summary' => $summary,
                    ],
                );

                return response()->json([
                    'data' => [
                        'guest_session_id' => (string) $session->session_id,
                        'child_id' => $childId,
                        'linked' => true,
                        'idempotent_replay' => false,
                        'migration_summary' => $summary,
                    ],
                ]);
            }
        );
    }

    private function migrateOwnership(string $guestSessionId, string $userId, string $childId): array
    {
        $operations = [
            'documents' => fn () => $this->updateDocuments($guestSessionId, $userId, $childId),
            'learning_packs' => fn () => $this->updateChildScopedModel(LearningPack::class, $guestSessionId, $userId, $childId),
            'games' => fn () => $this->updateChildScopedModel(Game::class, $guestSessionId, $userId, $childId),
            'game_results' => fn () => $this->updateChildScopedModel(GameResult::class, $guestSessionId, $userId, $childId),
            'quiz_sessions' => fn () => $this->updateChildScopedModel(QuizSession::class, $guestSessionId, $userId, $childId),
            'revision_sessions' => fn () => $this->updateChildScopedModel(RevisionSession::class, $guestSessionId, $userId, $childId),
        ];

        $summary = [];
        foreach ($operations as $key => $operation) {
            $summary[$key] = $operation();
        }

        return $summary;
    }

    private function updateDocuments(string $guestSessionId, string $userId, string $childId): int
    {
        return Document::where('owner_type', 'guest')
            ->where('owner_guest_session_id', $guestSessionId)
            ->update([
                'owner_type' => 'child',
                'owner_child_id' => $childId,
                'child_profile_id' => $childId,
                'user_id' => $userId,
                'updated_at' => now(),
            ]);
    }

    public function trackEvent(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'guest_session_id' => ['required', 'string', 'max:60'],
            'event_name' => ['required', 'string', 'in:scan_started,scan_uploaded,quiz_generated,quiz_completed,link_prompt_shown,link_prompt_accepted,link_prompt_skipped,guest_session_started,guest_session_linked'],
            'step' => ['nullable', 'string', 'max:100'],
            'instance_id' => ['nullable', 'string', 'max:100'],
            'metadata' => ['nullable', 'array'],
        ]);

        $session = GuestSession::where('session_id', $payload['guest_session_id'])->firstOrFail();
        $this->recordGuestEvent(
            sessionId: (string) $session->session_id,
            eventName: $payload['event_name'],
            step: $payload['step'] ?? 'guest_prelink',
            instanceId: $payload['instance_id'] ?? null,
            metadata: $payload['metadata'] ?? [],
        );

        return response()->json([
            'data' => [
                'recorded' => true,
                'event_name' => $payload['event_name'],
            ],
        ], 201);
    }

    private function createGuestIdentity(): array
    {
        $seed = Str::lower(Str::random(20));
        $user = User::create([
            'name' => 'Guest Learner '.$seed,
            'email' => 'guest+'.$seed.'@learny.local',
            'password' => Hash::make(Str::random(48)),
        ]);

        $child = \App\Models\ChildProfile::create([
            'user_id' => (string) $user->_id,
            'name' => 'Guest Learner',
            'grade_level' => '6th',
            'preferred_language' => 'en',
        ]);

        return [$user, $child];
    }

    private function updateChildScopedModel(string $modelClass, string $guestSessionId, string $userId, string $childId): int
    {
        return $modelClass::where('owner_type', 'guest')
            ->where('owner_guest_session_id', $guestSessionId)
            ->update([
                'owner_type' => 'child',
                'owner_child_id' => $childId,
                'child_profile_id' => $childId,
                'user_id' => $userId,
                'updated_at' => now(),
            ]);
    }

    private function recordGuestEvent(
        string $sessionId,
        string $eventName,
        string $step,
        ?string $instanceId = null,
        array $metadata = []
    ): void {
        OnboardingEvent::create([
            'user_id' => null,
            'role' => 'guest',
            'event_name' => $eventName,
            'step' => $step,
            'event_key' => sha1('guest|'.$sessionId.'|'.$eventName.'|'.$step.'|'.($instanceId ?? '')),
            'guest_session_id' => $sessionId,
            'occurred_at' => now(),
            'metadata' => $metadata,
        ]);
    }
}
