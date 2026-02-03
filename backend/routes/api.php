<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChildProfileController;
use App\Http\Controllers\Api\ChildProgressController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\GameController;
use App\Http\Controllers\Api\GameResultController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\LearningPackController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class);

Route::prefix('v1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:api')->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::post('/auth/refresh', [AuthController::class, 'refresh']);

        Route::apiResource('children', ChildProfileController::class)
            ->only(['index', 'store', 'show', 'update', 'destroy']);

        Route::get('children/{child}/mastery', [ChildProgressController::class, 'mastery']);
        Route::post('children/{child}/mastery', [ChildProgressController::class, 'upsertMastery']);
        Route::get('children/{child}/progress', [ChildProgressController::class, 'progress']);

        Route::get('children/{child}/documents', [DocumentController::class, 'index']);
        Route::post('children/{child}/documents', [DocumentController::class, 'store']);
        Route::get('children/{child}/documents/{document}', [DocumentController::class, 'show']);
        Route::post('children/{child}/documents/{document}/regenerate', [DocumentController::class, 'regenerate']);

        Route::get('children/{child}/learning-packs', [LearningPackController::class, 'index']);
        Route::post('children/{child}/learning-packs', [LearningPackController::class, 'store']);
        Route::get('children/{child}/learning-packs/{pack}', [LearningPackController::class, 'show']);

        Route::get('children/{child}/learning-packs/{pack}/games', [GameController::class, 'index']);
        Route::post('children/{child}/learning-packs/{pack}/games', [GameController::class, 'store']);
        Route::get('children/{child}/learning-packs/{pack}/games/{game}', [GameController::class, 'show']);

        Route::post('children/{child}/learning-packs/{pack}/games/{game}/results', [GameResultController::class, 'store']);
        Route::post('children/{child}/learning-packs/{pack}/games/{game}/retry', [GameController::class, 'retry']);
    });
});
