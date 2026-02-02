<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Storage;
use Throwable;

class HealthController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $checks = [
            'mongodb' => $this->checkMongo(),
            'redis' => $this->checkRedis(),
            'storage' => $this->checkStorage(),
        ];

        $ok = collect($checks)->every(fn (array $check) => $check['ok'] === true);

        return response()->json([
            'status' => $ok ? 'ok' : 'degraded',
            'checks' => $checks,
        ], $ok ? 200 : 503);
    }

    protected function checkMongo(): array
    {
        try {
            DB::connection('mongodb')
                ->getDatabase()
                ->command(['ping' => 1])
                ->toArray();

            return ['ok' => true];
        } catch (Throwable $e) {
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }

    protected function checkRedis(): array
    {
        try {
            Redis::connection()->ping();

            return ['ok' => true];
        } catch (Throwable $e) {
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }

    protected function checkStorage(): array
    {
        try {
            $diskName = config('filesystems.default', 'local');
            Storage::disk($diskName)->exists('healthcheck');

            return ['ok' => true, 'disk' => $diskName];
        } catch (Throwable $e) {
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }
}
