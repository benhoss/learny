<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class NotificationDeviceController extends Controller
{
    use FindsOwnedChild;

    public function store(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $userId = (string) Auth::guard('api')->id();
        $payload = $request->validate([
            'platform' => ['required', Rule::in(['ios', 'android', 'web'])],
            'token' => ['required', 'string', 'max:512'],
            'locale' => ['nullable', 'string', 'max:20'],
            'timezone' => ['nullable', 'string', 'max:64'],
        ]);

        $deviceToken = DeviceToken::firstOrNew([
            'user_id' => $userId,
            'child_id' => (string) $child->_id,
            'token' => $payload['token'],
        ]);

        $deviceToken->platform = $payload['platform'];
        $deviceToken->locale = $payload['locale'] ?? null;
        $deviceToken->timezone = $payload['timezone'] ?? null;
        $deviceToken->revoked_at = null;
        $deviceToken->last_seen_at = now();
        $deviceToken->save();

        return response()->json([
            'data' => $this->serialize($deviceToken),
        ], 201);
    }

    public function destroy(string $childId, string $deviceTokenId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $userId = (string) Auth::guard('api')->id();

        $deviceToken = DeviceToken::where('_id', $deviceTokenId)
            ->where('user_id', $userId)
            ->where('child_id', (string) $child->_id)
            ->firstOrFail();

        $deviceToken->revoked_at = now();
        $deviceToken->save();

        return response()->json([
            'data' => [
                'deviceTokenId' => (string) $deviceToken->_id,
                'revoked' => true,
            ],
        ]);
    }

    private function serialize(DeviceToken $deviceToken): array
    {
        return [
            'id' => (string) $deviceToken->_id,
            'platform' => (string) $deviceToken->platform,
            'token' => (string) $deviceToken->token,
            'locale' => $deviceToken->locale,
            'timezone' => $deviceToken->timezone,
            'revokedAt' => optional($deviceToken->revoked_at)->toISOString(),
            'lastSeenAt' => optional($deviceToken->last_seen_at)->toISOString(),
        ];
    }
}
