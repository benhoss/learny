<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\ChildProfile;
use App\Models\OnboardingEvent;
use App\Models\OnboardingLinkToken;
use App\Models\OnboardingState;
use App\Services\Onboarding\GradeByCountryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class OnboardingController extends Controller
{
    use FindsOwnedChild;

    private const EVENT_OPTIONS = [
        'onboarding_role_selected',
        'child_profile_created',
        'first_learning_started',
        'first_learning_completed',
        'scan_started',
        'scan_uploaded',
        'quiz_generated',
        'quiz_completed',
        'link_prompt_shown',
        'link_prompt_accepted',
        'link_prompt_skipped',
        'guest_session_started',
        'guest_session_linked',
        'parent_signup_completed',
        'child_link_code_generated',
        'child_device_linked',
        'parent_controls_configured',
    ];

    public function policy(Request $request): JsonResponse
    {
        $market = strtoupper((string) ($request->query('market') ?: config('learny.default_market', 'US')));
        $matrix = (array) config('learny.consent_age_by_market', []);
        $consentAge = (int) ($matrix[$market] ?? 13);

        return response()->json([
            'data' => [
                'market' => $market,
                'consent_age' => $consentAge,
                'requires_verified_parent_consent' => true,
            ],
        ]);
    }

    public function init(Request $request): JsonResponse
    {
        // 1. Detect Country
        $country = $request->header('CF-IPCountry');
        if (empty($country)) {
            // Fallback for local dev or non-CF environments
            $country = 'US'; 
        }
        $country = strtoupper($country);

        // 2. Load Grade Systems
        $systems = config('learny.grade_systems');
        
        return response()->json([
            'data' => [
                'detected_country' => $country,
                'grade_systems' => $systems, // Return all systems
                'supported_countries' => array_keys($systems),
            ],
        ]);
    }

    public function showState(): JsonResponse
    {
        $userId = (string) Auth::guard('api')->id();
        $states = OnboardingState::where('user_id', $userId)->get()->keyBy('role');

        return response()->json([
            'data' => [
                'child' => $this->serializeState($states->get('child')),
                'parent' => $this->serializeState($states->get('parent')),
            ],
        ]);
    }

    public function updateState(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'role' => ['required', 'string', 'in:child,parent'],
            'current_step' => ['required', 'string', 'max:100'],
            'checkpoints' => ['nullable', 'array'],
            'completed_steps' => ['nullable', 'array'],
            'completed_steps.*' => ['string', 'max:100'],
            'mark_complete' => ['nullable', 'boolean'],
        ]);

        $userId = (string) Auth::guard('api')->id();
        /** @var OnboardingState $state */
        $state = OnboardingState::firstOrNew([
            'user_id' => $userId,
            'role' => $payload['role'],
        ]);

        $state->current_step = $payload['current_step'];
        $state->checkpoints = $payload['checkpoints'] ?? $state->checkpoints ?? [];
        $state->completed_steps = array_values(array_unique(array_filter(
            array_merge(
                is_array($state->completed_steps ?? null) ? $state->completed_steps : [],
                $payload['completed_steps'] ?? []
            )
        )));
        $state->started_at ??= now();
        $state->last_seen_at = now();

        if (($payload['mark_complete'] ?? false) === true) {
            $checkpoints = array_merge(
                is_array($state->checkpoints ?? null) ? $state->checkpoints : [],
                is_array($payload['checkpoints'] ?? null) ? $payload['checkpoints'] : [],
            );
            if ($payload['role'] === 'child') {
                $this->assertChildCompletionAllowed($userId, $checkpoints);
            }
            $state->completed_at = now();
        }

        $state->save();

        return response()->json([
            'data' => $this->serializeState($state),
        ]);
    }

    public function trackEvent(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'role' => ['required', 'string', 'in:child,parent,guest'],
            'event_name' => ['required', 'string', 'in:'.implode(',', self::EVENT_OPTIONS)],
            'step' => ['nullable', 'string', 'max:100'],
            'instance_id' => ['nullable', 'string', 'max:100'],
            'metadata' => ['nullable', 'array'],
        ]);

        $userId = (string) Auth::guard('api')->id();
        /** @var OnboardingState $state */
        $state = OnboardingState::firstOrNew([
            'user_id' => $userId,
            'role' => $payload['role'],
        ]);

        $eventKey = sha1(
            $userId.'|'.$payload['role'].'|'.($payload['step'] ?? '').'|'.$payload['event_name'].'|'.($payload['instance_id'] ?? '')
        );

        $completedEvents = is_array($state->completed_events ?? null) ? $state->completed_events : [];
        if (in_array($eventKey, $completedEvents, true)) {
            return response()->json([
                'data' => [
                    'recorded' => false,
                    'event_name' => $payload['event_name'],
                ],
            ]);
        }

        $completedEvents[] = $eventKey;
        $state->completed_events = array_values(array_unique($completedEvents));
        $state->started_at ??= now();
        $state->last_seen_at = now();
        $state->save();

        OnboardingEvent::create([
            'user_id' => $userId,
            'role' => $payload['role'],
            'event_name' => $payload['event_name'],
            'step' => $payload['step'] ?? null,
            'event_key' => $eventKey,
            'occurred_at' => now(),
            'metadata' => $payload['metadata'] ?? [],
        ]);

        return response()->json([
            'data' => [
                'recorded' => true,
                'event_name' => $payload['event_name'],
            ],
        ], 201);
    }

    public function createLinkToken(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'child_id' => ['required', 'string'],
            'expires_in_seconds' => ['nullable', 'integer', 'min:60', 'max:1800'],
            'metadata' => ['nullable', 'array'],
        ]);

        $child = $this->findOwnedChild($payload['child_id']);
        $ttlSeconds = (int) ($payload['expires_in_seconds'] ?? 600);

        $code = (string) random_int(100000, 999999);
        $hash = hash('sha256', $code.'|'.config('app.key'));

        OnboardingLinkToken::where('child_profile_id', (string) $child->_id)
            ->whereNull('consumed_at')
            ->delete();

        $token = OnboardingLinkToken::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            'code_hash' => $hash,
            'expires_at' => now()->addSeconds($ttlSeconds),
            'failed_attempts' => 0,
            'locked_at' => null,
            'metadata' => $payload['metadata'] ?? [],
        ]);

        $this->recordGeneratedLinkCodeEvent();

        return response()->json([
            'data' => [
                'token_id' => (string) $token->_id,
                'child_id' => (string) $child->_id,
                'code' => $code,
                'expires_at' => optional($token->expires_at)?->toIso8601String(),
                'qr_payload' => json_encode([
                    'code' => $code,
                    'child_id' => (string) $child->_id,
                ]),
            ],
        ], 201);
    }

    public function consumeLinkToken(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'code' => ['required', 'string', 'size:6'],
            'child_id' => ['nullable', 'string'],
            'device_name' => ['required', 'string', 'max:100'],
            'device_platform' => ['nullable', 'string', 'max:40'],
        ]);

        $rateLimitKey = 'onboarding:consume:'.$request->ip();
        if (RateLimiter::tooManyAttempts($rateLimitKey, 8)) {
            return response()->json([
                'message' => 'Too many attempts. Try again later.',
            ], 429);
        }

        $hash = hash('sha256', $payload['code'].'|'.config('app.key'));

        /** @var OnboardingLinkToken|null $token */
        $token = OnboardingLinkToken::where('code_hash', $hash)->first();
        if (! $token) {
            RateLimiter::hit($rateLimitKey, 120);
            return response()->json([
                'message' => 'Invalid or expired link code.',
            ], 422);
        }

        if ($token->consumed_at !== null ||
            $token->expires_at === null ||
            $token->expires_at->isPast() ||
            $token->locked_at !== null) {
            RateLimiter::hit($rateLimitKey, 120);
            return response()->json([
                'message' => 'Invalid or expired link code.',
            ], 422);
        }

        if (filled($payload['child_id']) &&
            (string) $token->child_profile_id !== (string) $payload['child_id']) {
            $this->registerLinkConsumeFailure($token);
            RateLimiter::hit($rateLimitKey, 120);
            return response()->json([
                'message' => 'Invalid or expired link code.',
            ], 422);
        }

        return Cache::lock('onboarding:consume:'.$token->_id, 5)->block(
            2,
            function () use ($payload, $token, $rateLimitKey): JsonResponse {
                /** @var ChildProfile $child */
                $child = ChildProfile::where('_id', (string) $token->child_profile_id)->firstOrFail();

                $deviceId = 'dev_'.Str::lower(Str::random(16));
                $device = [
                    'id' => $deviceId,
                    'name' => $payload['device_name'],
                    'platform' => $payload['device_platform'] ?? 'unknown',
                    'linked_at' => now()->toIso8601String(),
                    'last_seen_at' => now()->toIso8601String(),
                ];

                $devices = is_array($child->linked_devices ?? null) ? $child->linked_devices : [];
                $devices[] = $device;
                $child->linked_devices = $devices;
                $child->save();

                $token->consumed_at = now();
                $token->consumed_device_id = $deviceId;
                $token->save();
                RateLimiter::clear($rateLimitKey);

                return response()->json([
                    'data' => [
                        'child_id' => (string) $child->_id,
                        'device' => $device,
                        'linked' => true,
                    ],
                ]);
            }
        );
    }

    private function assertChildCompletionAllowed(string $userId, array $checkpoints): void
    {
        $market = strtoupper((string) ($checkpoints['market'] ?? config('learny.default_market', 'US')));
        $matrix = (array) config('learny.consent_age_by_market', []);
        $consentAge = (int) ($matrix[$market] ?? 13);
        $minimumAge = $this->minimumAgeFromBracket($checkpoints['age_bracket'] ?? null);

        if ($minimumAge !== null && $minimumAge >= $consentAge) {
            return;
        }

        $childId = isset($checkpoints['child_id']) ? (string) $checkpoints['child_id'] : '';
        if ($childId !== '') {
            /** @var ChildProfile|null $child */
            $child = ChildProfile::where('_id', $childId)
                ->where('user_id', $userId)
                ->first();
            $devices = is_array($child?->linked_devices ?? null)
                ? $child->linked_devices
                : [];
            if ($devices !== []) {
                return;
            }
        } else {
            $children = ChildProfile::where('user_id', $userId)->get();
            if ($children->count() === 1) {
                $child = $children->first();
                $devices = is_array($child?->linked_devices ?? null)
                    ? $child->linked_devices
                    : [];
                if ($devices !== []) {
                    return;
                }
            }
        }

        throw ValidationException::withMessages([
            'consent' => [
                'Verified parent consent is required before completing onboarding for this market.',
            ],
        ]);
    }

    private function minimumAgeFromBracket(mixed $ageBracket): ?int
    {
        if (! is_string($ageBracket) || trim($ageBracket) === '') {
            return null;
        }

        $normalized = trim($ageBracket);
        if (str_contains($normalized, '-')) {
            $parts = explode('-', $normalized, 2);
            return is_numeric($parts[0]) ? (int) $parts[0] : null;
        }

        if (str_ends_with($normalized, '+')) {
            $base = rtrim($normalized, '+');
            return is_numeric($base) ? (int) $base : null;
        }

        return is_numeric($normalized) ? (int) $normalized : null;
    }

    private function registerLinkConsumeFailure(OnboardingLinkToken $token): void
    {
        $attempts = (int) ($token->failed_attempts ?? 0);
        $attempts += 1;
        $token->failed_attempts = $attempts;
        if ($attempts >= 5) {
            $token->locked_at = now();
        }
        $token->save();
    }

    public function listDevices(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $devices = is_array($child->linked_devices ?? null) ? $child->linked_devices : [];

        return response()->json([
            'data' => array_values($devices),
        ]);
    }

    public function revokeDevice(string $childId, string $deviceId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $devices = is_array($child->linked_devices ?? null) ? $child->linked_devices : [];

        $filtered = array_values(array_filter($devices, fn ($device) => (string) ($device['id'] ?? '') !== $deviceId));
        $child->linked_devices = $filtered;
        $child->save();

        return response()->json([
            'data' => [
                'revoked' => true,
                'device_id' => $deviceId,
            ],
        ]);
    }

    private function serializeState(?OnboardingState $state): array
    {
        return [
            'role' => $state?->role,
            'current_step' => $state?->current_step,
            'checkpoints' => is_array($state?->checkpoints) ? $state->checkpoints : [],
            'completed_steps' => is_array($state?->completed_steps) ? $state->completed_steps : [],
            'completed_events' => is_array($state?->completed_events) ? $state->completed_events : [],
            'started_at' => optional($state?->started_at)?->toIso8601String(),
            'completed_at' => optional($state?->completed_at)?->toIso8601String(),
            'last_seen_at' => optional($state?->last_seen_at)?->toIso8601String(),
        ];
    }

    private function recordGeneratedLinkCodeEvent(): void
    {
        $userId = (string) Auth::guard('api')->id();
        /** @var OnboardingState $state */
        $state = OnboardingState::firstOrNew([
            'user_id' => $userId,
            'role' => 'parent',
        ]);

        $events = is_array($state->completed_events ?? null) ? $state->completed_events : [];
        if (! in_array('child_link_code_generated', $events, true)) {
            $events[] = 'child_link_code_generated';
            $state->completed_events = array_values(array_unique($events));
            $state->started_at ??= now();
            $state->last_seen_at = now();
            $state->save();

            OnboardingEvent::create([
                'user_id' => $userId,
                'role' => 'parent',
                'event_name' => 'child_link_code_generated',
                'step' => 'link_child_device',
                'event_key' => sha1($userId.'|parent|child_link_code_generated'),
                'occurred_at' => now(),
                'metadata' => [],
            ]);
        }
    }
}

