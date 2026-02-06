<?php

namespace App\Providers;

use App\Services\Concepts\ConceptExtractorInterface;
use App\Services\Concepts\PrismConceptExtractor;
use App\Services\Concepts\StubConceptExtractor;
use App\Services\Generation\LearningPackGeneratorInterface;
use App\Services\Generation\PrismLearningPackGenerator;
use App\Services\Generation\StubLearningPackGenerator;
use App\Services\Generation\GameGeneratorInterface;
use App\Services\Generation\PrismGameGenerator;
use App\Services\Generation\StubGameGenerator;
use App\Services\Ocr\PrismOcrClient;
use App\Services\Ocr\OcrClientInterface;
use App\Services\Ocr\StubOcrClient;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        if (config('prism.providers.mistral.api_key')) {
            $this->app->bind(OcrClientInterface::class, PrismOcrClient::class);
        } else {
            $this->app->bind(OcrClientInterface::class, StubOcrClient::class);
        }

        if (config('prism.providers.openrouter.api_key')) {
            $this->app->bind(ConceptExtractorInterface::class, PrismConceptExtractor::class);
        } else {
            $this->app->bind(ConceptExtractorInterface::class, StubConceptExtractor::class);
        }

        if (config('prism.providers.openrouter.api_key')) {
            $this->app->bind(LearningPackGeneratorInterface::class, PrismLearningPackGenerator::class);
        } else {
            $this->app->bind(LearningPackGeneratorInterface::class, StubLearningPackGenerator::class);
        }

        if (config('prism.providers.openrouter.api_key')) {
            $this->app->bind(GameGeneratorInterface::class, PrismGameGenerator::class);
        } else {
            $this->app->bind(GameGeneratorInterface::class, StubGameGenerator::class);
        }
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(120)->by($request->user()?->id ?: $request->ip()));

        RateLimiter::for('api-write', fn (Request $request) => Limit::perMinute(30)->by($request->user()?->id ?: $request->ip()));
    }
}
