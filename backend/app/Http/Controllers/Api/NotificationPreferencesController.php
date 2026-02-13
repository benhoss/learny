<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Services\Notifications\NotificationPreferenceResolver;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationPreferencesController extends Controller
{
    use FindsOwnedChild;

    public function __construct(private readonly NotificationPreferenceResolver $resolver) {}

    public function show(string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $userId = (string) Auth::guard('api')->id();

        return response()->json([
            'data' => $this->resolver->loadResolved($userId, (string) $child->_id),
        ]);
    }

    public function update(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $payload = $request->validate($this->rules());
        $userId = (string) Auth::guard('api')->id();

        return response()->json([
            'data' => $this->resolver->updateFromPayload($userId, (string) $child->_id, $payload),
        ]);
    }

    private function rules(): array
    {
        return [
            'globalParentDefaults' => ['sometimes', 'array'],
            'childOverrides' => ['sometimes', 'array'],

            'globalParentDefaults.channels' => ['sometimes', 'array'],
            'globalParentDefaults.channels.push' => ['sometimes', 'boolean'],
            'globalParentDefaults.channels.email' => ['sometimes', 'boolean'],
            'globalParentDefaults.channels.inApp' => ['sometimes', 'boolean'],

            'globalParentDefaults.quietHours' => ['sometimes', 'array'],
            'globalParentDefaults.quietHours.startLocal' => ['sometimes', 'date_format:H:i'],
            'globalParentDefaults.quietHours.endLocal' => ['sometimes', 'date_format:H:i'],
            'globalParentDefaults.timezone' => ['sometimes', 'string', 'max:64'],

            'globalParentDefaults.caps' => ['sometimes', 'array'],
            'globalParentDefaults.caps.daily' => ['sometimes', 'integer', 'min:0', 'max:10'],
            'globalParentDefaults.caps.weekly' => ['sometimes', 'integer', 'min:0', 'max:30'],

            'childOverrides.channels' => ['sometimes', 'array'],
            'childOverrides.channels.push' => ['sometimes', 'boolean'],
            'childOverrides.channels.email' => ['sometimes', 'boolean'],
            'childOverrides.channels.inApp' => ['sometimes', 'boolean'],

            'childOverrides.quietHours' => ['sometimes', 'array'],
            'childOverrides.quietHours.startLocal' => ['sometimes', 'date_format:H:i'],
            'childOverrides.quietHours.endLocal' => ['sometimes', 'date_format:H:i'],
            'childOverrides.timezone' => ['sometimes', 'string', 'max:64'],

            'childOverrides.caps' => ['sometimes', 'array'],
            'childOverrides.caps.daily' => ['sometimes', 'integer', 'min:0', 'max:10'],
            'childOverrides.caps.weekly' => ['sometimes', 'integer', 'min:0', 'max:30'],
        ];
    }
}
