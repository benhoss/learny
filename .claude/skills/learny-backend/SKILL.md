---
name: learny-backend
description: "This skill should be used when implementing features, fixing bugs, or making changes in the Learny Laravel 12 + MongoDB backend. This includes creating or modifying models, controllers, services, jobs, routes, migrations, and tests. Triggers on any backend PHP work, API endpoint changes, database schema changes, queue job modifications, or when adding new game types, processing pipeline stages, or mastery/gamification logic."
---

# Learny Backend Implementation

## Stack

- PHP 8.2+, Laravel 12, MongoDB 7 (`mongodb/laravel-mongodb` v5.5)
- JWT auth (`php-open-source-saver/jwt-auth`), Prism PHP for LLM calls via OpenRouter/Mistral
- S3/MinIO for file storage, Redis for queues
- Docker: web (8081), mongo (27117), redis (6380), minio (9002/9003)

## Architecture Reference

For model schemas, API route catalog, service interfaces, factory definitions, and collection structures, read `references/architecture.md`.

## Critical Rules

### MongoDB Models

- Extend `MongoDB\Laravel\Eloquent\Model` (not Illuminate). `User` extends `MongoDB\Laravel\Auth\User`.
- Cast `_id` to string for foreign keys: `'user_id' => (string) $user->_id`
- **NEVER set array defaults in `$attributes`** for array-cast fields. `getDirty()` -> `fromJson()` -> `json_decode()` fails with TypeError on PHP arrays. Omit defaults; MongoDB handles missing fields.

### Validation

- **Array format only**: `['required', 'string', 'max:100']` — each rule is a separate element
- **NEVER pipe-delimited inside arrays**: `['sometimes|required']` crashes. Use `['sometimes', 'required']`.

### Controller Pattern

```php
use App\Concerns\FindsOwnedChild;
use App\Http\Controllers\Controller;

class NewFeatureController extends Controller
{
    use FindsOwnedChild;

    public function index(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $items = Model::where('child_profile_id', (string) $child->_id)->get();
        return response()->json(['data' => $items]);
    }

    public function store(Request $request, string $childId): JsonResponse
    {
        $child = $this->findOwnedChild($childId);
        $data = $request->validate([
            'field' => ['required', 'string', 'max:255'],
        ]);
        $record = Model::create([
            'user_id' => (string) Auth::guard('api')->id(),
            'child_profile_id' => (string) $child->_id,
            ...$data,
        ]);
        return response()->json(['data' => $record], 201);
    }
}
```

### Routes

Register in `routes/api.php`. Two groups:
- Read (120/min): `Route::middleware(['auth:api', 'throttle:api'])`
- Write (30/min): `Route::middleware(['auth:api', 'throttle:api-write'])`

All routes prefixed `/v1`. Child-scoped routes nest under `/v1/children/{child}/`.

### Service Layer

AI services use interface + implementation pattern. Interface in `app/Services/{Domain}/`. Real impl uses Prism PHP with `RetriesLlmCalls` trait. Stub for tests. Bound in `AppServiceProvider::register()` based on API key presence.

### Job Pipeline

Sequential chain where each job dispatches the next:

```
ProcessDocumentOcr [ocr] -> ExtractConceptsFromDocument [concepts]
  -> GenerateLearningPackFromDocument [pack] -> GenerateGamesFromLearningPack [games]
```

Track progress via `PipelineTelemetry::transition($document, $stage, $progressHint)` and `PipelineTelemetry::complete()`.

### Idempotency

Game results and revision submissions use `firstOrCreate` on compound keys. Check `$record->wasRecentlyCreated` to distinguish first submission from replay.

### Mastery & Streak

Updated inline in `GameResultController::store()`, not via jobs:
- `updateMastery()`: groups by topic, upserts `MasteryProfile` with SRS (wrong=1d, right=3d, right 2x=7d)
- `updateStreak()`: atomic compare-and-set on `last_activity_date`
- `recordLearningMemoryEvents()`: creates events per question result

## Writing Tests

Base `TestCase` drops all MongoDB collections in `setUp()`. Tests go in `tests/Feature/`.

```php
public function test_creates_resource(): void
{
    $user = User::factory()->create();
    $token = Auth::guard('api')->login($user);
    $child = ChildProfile::factory()->create(['user_id' => (string) $user->_id]);

    $response = $this->withHeader('Authorization', 'Bearer ' . $token)
        ->postJson('/api/v1/children/' . $child->_id . '/resource', [
            'field' => 'value',
        ]);

    $response->assertStatus(201);
    $response->assertJsonPath('data.field', 'value');
}
```

Mock AI services by binding stubs:

```php
$this->app->bind(OcrClientInterface::class, fn () => new class implements OcrClientInterface {
    public function extractText(string $disk, string $path, ?string $mimeType = null): string {
        return 'Mock text';
    }
});
```

## Commands

```bash
docker compose run --rm app php artisan test                          # All tests
docker compose run --rm app php artisan test --filter=MyTest          # Single test
docker compose run --rm --no-deps app php -l path/to/File.php        # Syntax check
docker compose run --rm app ./vendor/bin/pint                         # Lint
```

## New Feature Checklist

1. **Model** in `app/Models/` — extend MongoDB Model, define `$collection`, `$casts`, relations. No array defaults.
2. **Migration** in `database/migrations/` — add indexes for query patterns.
3. **Factory** in `database/factories/` — sensible defaults, `null` for relationship IDs.
4. **Controller** in `app/Http/Controllers/Api/` — use `FindsOwnedChild`, validate, return JSON.
5. **Routes** in `routes/api.php` — register under appropriate throttle group.
6. **Test** in `tests/Feature/` — happy path, validation errors, ownership scoping.
7. **Lint** — `docker compose run --rm app ./vendor/bin/pint`
8. **Run test** — `docker compose run --rm app php artisan test --filter=YourTest`

## Gotchas

- Pre-existing test failures: `DocumentUploadTest` and `OcrJobTest` (status 'ready' vs 'processed') — unrelated to new features
- Test passwords: factory default `'password'`, seeders use `'secret123'`
- `QUEUE_CONNECTION=sync` in tests for synchronous job execution
- `BOUND_CHILD_PROFILE_ID` and `DEMO_USER_*` must NOT be set in production (enforced in AppServiceProvider boot)
- Game payload `topic` field must match `concept_key` from learning pack concepts
- JSON schema validation for game payloads in `resources/schemas/game_{type}.json`
