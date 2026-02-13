<?php

use App\Http\Controllers\Api\InternalNotificationController;
use Illuminate\Support\Facades\Route;

Route::prefix('internal')
    ->middleware(['internal.notifications.auth', 'throttle:api-write'])
    ->group(function () {
        Route::post('notifications/trigger', [InternalNotificationController::class, 'trigger']);
        Route::post('notifications/retry/{eventId}', [InternalNotificationController::class, 'retry']);
        Route::post('notifications/simulate', [InternalNotificationController::class, 'simulate']);
    });
