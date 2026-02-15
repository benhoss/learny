<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChildProfileController;
use App\Http\Controllers\Api\ChildProgressController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\DocumentScanController;
use App\Http\Controllers\Api\DocumentMetadataSuggestionController;
use App\Http\Controllers\Api\GameController;
use App\Http\Controllers\Api\GameResultController;
use App\Http\Controllers\Api\GuestSessionController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\HomeRecommendationController;
use App\Http\Controllers\Api\LearningPackController;
use App\Http\Controllers\Api\MemoryPreferencesController;
use App\Http\Controllers\Api\NotificationDeviceController;
use App\Http\Controllers\Api\NotificationInboxController;
use App\Http\Controllers\Api\NotificationPreferencesController;
use App\Http\Controllers\Api\OnboardingController;
use App\Http\Controllers\Api\QuizSessionController;
use App\Http\Controllers\Api\RevisionSessionController;
use App\Http\Controllers\Api\ReviewQueueController;
use App\Http\Controllers\Api\SchoolAssessmentController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class);

Route::prefix('v1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/onboarding/link-tokens/consume', [OnboardingController::class, 'consumeLinkToken'])
        ->middleware('throttle:api-write');
    Route::get('/onboarding/policy', [OnboardingController::class, 'policy']);
    Route::get('/onboarding/init', [OnboardingController::class, 'init']);
    Route::post('/guest/session', [GuestSessionController::class, 'create'])
        ->middleware('throttle:api-write');
    Route::post('/guest/events', [GuestSessionController::class, 'trackEvent'])
        ->middleware('throttle:api-write');

    Route::middleware(['auth:api', 'throttle:api'])->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::post('/auth/refresh', [AuthController::class, 'refresh']);
        Route::get('/onboarding/state', [OnboardingController::class, 'showState']);

        Route::apiResource('children', ChildProfileController::class)
            ->only(['index', 'show']);

        Route::get('children/{child}/mastery', [ChildProgressController::class, 'mastery']);
        Route::get('children/{child}/progress', [ChildProgressController::class, 'progress']);
        Route::get('children/{child}/home-recommendations', [HomeRecommendationController::class, 'index']);
        Route::get('children/{child}/memory/preferences', [MemoryPreferencesController::class, 'show']);
        Route::get('children/{child}/notification-preferences', [NotificationPreferencesController::class, 'show']);
        Route::get('children/{child}/notifications', [NotificationInboxController::class, 'childInbox']);
        Route::get('notifications/parent-inbox', [NotificationInboxController::class, 'parentInbox']);
        Route::get('children/{child}/school-assessments', [SchoolAssessmentController::class, 'index']);

        Route::get('children/{child}/documents', [DocumentController::class, 'index']);
        Route::get('children/{child}/documents/{document}', [DocumentController::class, 'show']);
        Route::get('children/{child}/documents/{document}/scan', [DocumentScanController::class, 'show']);
        Route::post('children/{child}/documents/metadata-suggestions', [DocumentMetadataSuggestionController::class, 'suggest']);

        Route::get('children/{child}/learning-packs', [LearningPackController::class, 'index']);
        Route::get('children/{child}/learning-packs/{pack}', [LearningPackController::class, 'show']);

        Route::get('children/{child}/learning-packs/{pack}/games', [GameController::class, 'index']);
        Route::get('children/{child}/learning-packs/{pack}/games/{game}', [GameController::class, 'show']);
        Route::get('children/{child}/activities', [GameResultController::class, 'index']);

        Route::get('children/{child}/review-queue', [ReviewQueueController::class, 'index']);
        Route::get('children/{child}/revision-session', [RevisionSessionController::class, 'start']);
        Route::get('children/{child}/quiz-sessions/active', [QuizSessionController::class, 'active']);

        // Write endpoints with stricter rate limiting.
        Route::middleware('throttle:api-write')->group(function () {
            Route::apiResource('children', ChildProfileController::class)
                ->only(['store', 'update', 'destroy']);

            Route::post('children/{child}/mastery', [ChildProgressController::class, 'upsertMastery']);
            Route::post('children/{child}/school-assessments', [SchoolAssessmentController::class, 'store']);
            Route::patch('children/{child}/school-assessments/{assessment}', [SchoolAssessmentController::class, 'update']);
            Route::delete('children/{child}/school-assessments/{assessment}', [SchoolAssessmentController::class, 'destroy']);
            Route::put('children/{child}/memory/preferences', [MemoryPreferencesController::class, 'update']);
            Route::put('children/{child}/notification-preferences', [NotificationPreferencesController::class, 'update']);
            Route::post('children/{child}/notification-devices', [NotificationDeviceController::class, 'store']);
            Route::delete('children/{child}/notification-devices/{deviceTokenId}', [NotificationDeviceController::class, 'destroy']);
            Route::post('children/{child}/notifications/{id}/read', [NotificationInboxController::class, 'markRead']);
            Route::post('children/{child}/notifications/{id}/open', [NotificationInboxController::class, 'markOpen']);
            Route::post('children/{child}/memory/clear-scope', [MemoryPreferencesController::class, 'clearScope']);
            Route::post('children/{child}/home-recommendations/events', [HomeRecommendationController::class, 'track']);

            Route::post('children/{child}/documents', [DocumentController::class, 'store']);
            Route::post('children/{child}/documents/{document}/regenerate', [DocumentController::class, 'regenerate']);
            Route::post('children/{child}/documents/{document}/confirm-scan', [DocumentScanController::class, 'confirm']);
            Route::post('children/{child}/documents/{document}/rescan', [DocumentScanController::class, 'rescan']);

            Route::post('children/{child}/learning-packs', [LearningPackController::class, 'store']);

            Route::post('children/{child}/learning-packs/{pack}/games', [GameController::class, 'store']);

            Route::post('children/{child}/learning-packs/{pack}/games/{game}/results', [GameResultController::class, 'store']);
            Route::post('children/{child}/learning-packs/{pack}/games/{game}/quiz-sessions', [QuizSessionController::class, 'create']);
            Route::post('children/{child}/learning-packs/{pack}/games/{game}/retry', [GameController::class, 'retry']);
            Route::patch('children/{child}/quiz-sessions/{session}', [QuizSessionController::class, 'update']);
            Route::post('children/{child}/revision-session/{session}', [RevisionSessionController::class, 'submit']);
            Route::put('/onboarding/state', [OnboardingController::class, 'updateState']);
            Route::post('/onboarding/events', [OnboardingController::class, 'trackEvent']);
            Route::post('/onboarding/link-tokens', [OnboardingController::class, 'createLinkToken']);
            Route::post('/guest/link-account', [GuestSessionController::class, 'linkAccount']);
            Route::get('children/{child}/devices', [OnboardingController::class, 'listDevices']);
            Route::delete('children/{child}/devices/{device}', [OnboardingController::class, 'revokeDevice']);
        });
    });
});
