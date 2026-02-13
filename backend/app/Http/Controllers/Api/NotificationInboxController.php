<?php

namespace App\Http\Controllers\Api;

use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;
use App\Models\NotificationEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationInboxController extends Controller
{
    use FindsOwnedChild;

    public function childInbox(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $userId = (string) Auth::guard('api')->id();

        $items = $this->fetchPage(
            NotificationEvent::where('recipient_user_id', $userId)
                ->where('child_id', (string) $child->_id)
                ->where('channel', 'in_app')
                ->orderByDesc('created_at')
                ->orderByDesc('_id'),
            (string) $request->query('cursor', '')
        );

        return response()->json($items);
    }

    public function parentInbox(Request $request): JsonResponse
    {
        $userId = (string) Auth::guard('api')->id();
        $items = $this->fetchPage(
            NotificationEvent::where('recipient_user_id', $userId)
                ->where('audience', 'parent')
                ->where('channel', 'in_app')
                ->orderByDesc('created_at')
                ->orderByDesc('_id'),
            (string) $request->query('cursor', '')
        );

        return response()->json($items);
    }

    public function markRead(string $childId, string $notificationId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $userId = (string) Auth::guard('api')->id();

        $event = NotificationEvent::where('_id', $notificationId)
            ->where('recipient_user_id', $userId)
            ->where('child_id', (string) $child->_id)
            ->where('channel', 'in_app')
            ->firstOrFail();

        $event->read_at = now();
        $event->save();

        return response()->json([
            'data' => ['id' => (string) $event->_id, 'read' => true],
        ]);
    }

    public function markOpen(string $childId, string $notificationId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $userId = (string) Auth::guard('api')->id();

        $event = NotificationEvent::where('_id', $notificationId)
            ->where('recipient_user_id', $userId)
            ->where('child_id', (string) $child->_id)
            ->where('channel', 'in_app')
            ->firstOrFail();

        $event->opened_at = now();
        $event->status = 'opened';
        $event->save();

        return response()->json([
            'data' => ['id' => (string) $event->_id, 'opened' => true],
        ]);
    }

    /**
     * @param  \MongoDB\Laravel\Eloquent\Builder<NotificationEvent>  $query
     */
    private function fetchPage($query, string $cursor): array
    {
        $perPage = 20;
        $decoded = $this->decodeCursor($cursor);

        if ($decoded !== null) {
            [$createdAt, $id] = $decoded;
            $query->where(function ($q) use ($createdAt, $id): void {
                $q->where('created_at', '<', $createdAt)
                    ->orWhere(function ($q2) use ($createdAt, $id): void {
                        $q2->where('created_at', $createdAt)->where('_id', '<', $id);
                    });
            });
        }

        $items = $query->limit($perPage + 1)->get();
        $hasMore = $items->count() > $perPage;
        $trimmed = $items->take($perPage)->values();

        $nextCursor = null;
        if ($hasMore && $trimmed->isNotEmpty()) {
            $last = $trimmed->last();
            $nextCursor = base64_encode(
                (string) optional($last->created_at)->toISOString().'|'.(string) $last->_id
            );
        }

        return [
            'data' => $trimmed->map(fn (NotificationEvent $event): array => $this->serialize($event))->all(),
            'meta' => [
                'nextCursor' => $nextCursor,
            ],
        ];
    }

    /**
     * @return array{0: string, 1: string}|null
     */
    private function decodeCursor(string $cursor): ?array
    {
        if ($cursor === '') {
            return null;
        }

        $decoded = base64_decode($cursor, true);
        if (! is_string($decoded) || $decoded === '' || ! str_contains($decoded, '|')) {
            return null;
        }

        [$createdAt, $id] = explode('|', $decoded, 2);
        if ($createdAt === '' || $id === '') {
            return null;
        }

        return [$createdAt, $id];
    }

    private function serialize(NotificationEvent $event): array
    {
        return [
            'id' => (string) $event->_id,
            'campaignKey' => (string) $event->campaign_key,
            'channel' => (string) $event->channel,
            'status' => (string) $event->status,
            'priority' => (string) ($event->priority ?? 'normal'),
            'readAt' => optional($event->read_at)->toISOString(),
            'openedAt' => optional($event->opened_at)->toISOString(),
            'sentAt' => optional($event->sent_at)->toISOString(),
            'createdAt' => optional($event->created_at)->toISOString(),
            'contextPayload' => (array) ($event->context_payload ?? []),
        ];
    }
}
