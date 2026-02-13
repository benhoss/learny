<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class InternalNotificationsAuth
{
    public function handle(Request $request, Closure $next): Response
    {
        $configuredToken = (string) config('learny.notifications.internal_token', '');
        $providedToken = (string) $request->header('X-Internal-Token', '');

        if ($configuredToken === '' || ! hash_equals($configuredToken, $providedToken)) {
            return response()->json([
                'error' => [
                    'code' => 'unauthorized',
                    'message' => 'Invalid internal token.',
                    'details' => (object) [],
                ],
            ], 401);
        }

        $allowlist = (array) config('learny.notifications.internal_allowlist', []);
        if (app()->environment('testing') || $allowlist === []) {
            return $next($request);
        }

        $clientIp = (string) ($request->ip() ?? '');
        if (! in_array($clientIp, $allowlist, true)) {
            return response()->json([
                'error' => [
                    'code' => 'forbidden',
                    'message' => 'Request IP is not allowlisted.',
                    'details' => (object) [],
                ],
            ], 403);
        }

        return $next($request);
    }
}
