# Learny Backend Architecture Reference

## MongoDB Collections & Models

All models extend `MongoDB\Laravel\Eloquent\Model`. Foreign keys are always cast to string: `(string) $model->_id`.

### users
- Model: `App\Models\User` (extends `MongoDB\Laravel\Auth\User`)
- Implements `JWTSubject`
- Fields: `name`, `email`, `password`
- Relations: `hasMany(ChildProfile)`

### child_profiles
- Model: `App\Models\ChildProfile`
- Fields: `user_id`, `name`, `grade_level`, `birth_year`, `school_class`, `preferred_language` (en/fr/nl), `gender`, `gender_self_description`, `learning_style_preferences` (array), `support_needs` (array), `confidence_by_subject` (array), `streak_days`, `longest_streak`, `last_activity_date`, `total_xp`, `memory_personalization_enabled`, `recommendation_why_enabled`, `recommendation_why_level`
- Casts: arrays, dates, integers, booleans
- Relations: `belongsTo(User)`, `hasMany(MasteryProfile)`, `hasMany(Document)`, `hasMany(Concept)`, `hasMany(LearningPack)`, `hasMany(SchoolAssessment)`
- Appends: `age` (computed from `birth_year`)
- Setters: `setPreferredLanguageAttribute()` normalizes to en/fr/nl, `setGenderAttribute()` clears self_description if not 'self_describe'
- Boot: cascades delete to `schoolAssessments`
- Indexes: `[user_id]`

### documents
- Model: `App\Models\Document`
- Fields: `user_id`, `child_profile_id`, `status`, `original_filename`, `storage_disk`, `storage_path`, `storage_paths` (array), `mime_type`, `mime_types` (array), `extracted_text`, `ocr_error`, `processed_at`, `subject`, `language`, `grade_level`, `learning_goal`, `context_text`, `requested_game_types` (array), `pipeline_stage`, `stage_started_at`, `stage_completed_at`, `progress_hint`, `first_playable_at`, `first_playable_game_type`, `ready_game_types` (array), `stage_timings` (array), `stage_history` (array)
- Status flow: `queued` -> `processing` -> `processed` -> `ready` (or `failed`)
- Pipeline stages: `ocr` -> `concept_extraction` -> `learning_pack_generation` -> `game_generation` -> `ready`
- Relations: `belongsTo(ChildProfile)`, `hasMany(Concept)`

### concepts
- Model: `App\Models\Concept`
- Fields: `child_profile_id`, `document_id`, `concept_key`, `concept_label`, `difficulty` (float)

### learning_packs
- Model: `App\Models\LearningPack`
- Fields: `user_id`, `child_profile_id`, `document_id`, `title`, `summary`, `status`, `schema_version`, `content` (array)
- Content structure: `{ objective, concepts: [{key, label, difficulty}], items: [{type, content}] }`
- Relations: `hasMany(Game)`, `belongsTo(ChildProfile)`
- Indexes: `[child_profile_id, document_id]`

### games
- Model: `App\Models\Game`
- Fields: `user_id`, `child_profile_id`, `learning_pack_id`, `type`, `schema_version`, `payload` (array), `status`
- Types: `flashcards`, `quiz`, `matching`, `true_false`, `fill_blank`, `ordering`, `multiple_select`, `short_answer`
- Payload validated against JSON schema files in `resources/schemas/`
- Indexes: `[learning_pack_id, child_profile_id]`

### game_results
- Model: `App\Models\GameResult`
- Fields: `user_id`, `child_profile_id`, `learning_pack_id`, `game_id`, `game_type`, `schema_version`, `game_payload` (array), `results` (array), `score`, `total_questions`, `correct_answers`, `xp_earned`, `language`, `metadata` (array), `completed_at`
- Idempotent: `firstOrCreate` on `[child_profile_id, game_id]`
- Indexes: `[user_id, child_profile_id]`

### mastery_profiles
- Model: `App\Models\MasteryProfile`
- Fields: `child_profile_id`, `concept_key`, `concept_label`, `mastery_level` (float 0-1), `total_attempts`, `correct_attempts`, `last_attempt_at`, `next_review_at`, `consecutive_correct`
- Unique constraint: `[child_profile_id, concept_key]`
- Indexes: `[child_profile_id, next_review_at]`
- SRS: wrong=1d, right once=3d, right 2x=7d

### school_assessments
- Model: `App\Models\SchoolAssessment`
- Fields: `child_profile_id`, `subject`, `assessment_type`, `score`, `max_score`, `grade`, `assessed_at`, `teacher_note`, `source` (default: 'manual')
- Appends: `score_percent` (computed)
- Hidden: `child_profile_id`

### revision_sessions
- Model: `App\Models\RevisionSession`
- Fields: `user_id`, `child_profile_id`, `source`, `status`, `started_at`, `completed_at`, `total_items`, `correct_items`, `xp_earned`, `subject_label`, `duration_minutes`, `items` (array), `results` (array)

### learning_memory_events
- Model: `App\Models\LearningMemoryEvent`
- Fields: `user_id`, `child_profile_id`, `concept_key`, `event_type`, `event_key`, `event_order`, `source_type`, `source_id`, `occurred_at`, `confidence`, `metadata` (array)
- Indexes: `[event_order]`

## API Routes

All under `/api/v1`. Auth routes are public. Everything else requires `auth:api` middleware.

### Public
```
POST /v1/auth/register    {name, email, password}
POST /v1/auth/login       {email, password}
GET  /health
```

### Read (throttle: 120/min)
```
GET    /v1/auth/me
POST   /v1/auth/logout
POST   /v1/auth/refresh
GET    /v1/children
GET    /v1/children/{child}
GET    /v1/children/{child}/mastery
GET    /v1/children/{child}/progress
GET    /v1/children/{child}/home-recommendations
GET    /v1/children/{child}/memory/preferences
GET    /v1/children/{child}/school-assessments
GET    /v1/children/{child}/documents
GET    /v1/children/{child}/documents/{document}
POST   /v1/children/{child}/documents/metadata-suggestions
GET    /v1/children/{child}/learning-packs
GET    /v1/children/{child}/learning-packs/{pack}
GET    /v1/children/{child}/learning-packs/{pack}/games
GET    /v1/children/{child}/learning-packs/{pack}/games/{game}
GET    /v1/children/{child}/activities
GET    /v1/children/{child}/review-queue
GET    /v1/children/{child}/revision-session
```

### Write (throttle: 30/min)
```
POST   /v1/children                                           Create child
PATCH  /v1/children/{child}                                   Update child
DELETE /v1/children/{child}                                   Delete child
POST   /v1/children/{child}/school-assessments                Create assessment
PATCH  /v1/children/{child}/school-assessments/{assessment}   Update assessment
DELETE /v1/children/{child}/school-assessments/{assessment}   Delete assessment
PUT    /v1/children/{child}/memory/preferences                Update memory prefs
POST   /v1/children/{child}/memory/clear-scope                Clear memory scope
POST   /v1/children/{child}/home-recommendations/events       Track recommendation
POST   /v1/children/{child}/documents                         Upload document
POST   /v1/children/{child}/documents/{document}/regenerate   Re-run pipeline
POST   /v1/children/{child}/learning-packs                    Create pack
POST   /v1/children/{child}/learning-packs/{pack}/games       Create game
POST   /v1/children/{child}/learning-packs/{pack}/games/{game}/results  Submit result
POST   /v1/children/{child}/learning-packs/{pack}/games/{game}/retry    Create retry game
POST   /v1/children/{child}/revision-session/{session}        Submit revision
```

## Service Interfaces

| Interface | Real Implementation | Stub | Provider |
|-----------|-------------------|------|----------|
| `OcrClientInterface` | `PrismOcrClient` (Mistral) | `StubOcrClient` | Mistral API key |
| `ConceptExtractorInterface` | `PrismConceptExtractor` (OpenRouter) | `StubConceptExtractor` | OpenRouter API key |
| `LearningPackGeneratorInterface` | `PrismLearningPackGenerator` (OpenRouter) | `StubLearningPackGenerator` | OpenRouter API key |
| `GameGeneratorInterface` | `PrismGameGenerator` (OpenRouter) | `StubGameGenerator` | OpenRouter API key |

Bindings in `AppServiceProvider::register()` — real impl if API key configured, stub otherwise.

## Job Pipeline

Sequential dispatch: each job dispatches the next on success.

```
ProcessDocumentOcr        [queue: ocr]
  -> ExtractConceptsFromDocument  [queue: concepts]
    -> GenerateLearningPackFromDocument  [queue: pack]
      -> GenerateGamesFromLearningPack   [queue: games]
```

Progress tracked via `PipelineTelemetry::transition()` and `PipelineTelemetry::complete()`.

## JSON Schema Files

Location: `resources/schemas/`

- `learning_pack.json` - Pack content validation
- `game_quiz.json` - Quiz payload (questions with prompt/choices/answer_index)
- `game_flashcards.json` - Flashcards payload (cards with front/back)
- `game_matching.json` - Matching payload (pairs with left/right)
- `game_true_false.json` - True/false payload (questions with statement/answer)
- `game_fill_blank.json` - Fill blank payload
- `game_ordering.json` - Ordering payload (items with prompt/sequence)
- `game_multiple_select.json` - Multiple select payload
- `game_short_answer.json` - Short answer payload

## Factories

Location: `database/factories/`

| Factory | Key Defaults |
|---------|-------------|
| `UserFactory` | password: 'password' |
| `ChildProfileFactory` | grade_level: random 5th/6th/7th, preferred_language: random en/fr/nl |
| `DocumentFactory` | status: 'queued', mime_type: 'application/pdf' |
| `LearningPackFactory` | status: 'ready', content with one concept 'fractions.addition' |
| `GameFactory` | type: 'flashcards', status: 'ready' |
| `MasteryProfileFactory` | mastery_level: 0.5, total_attempts: 10 |
| `ConceptFactory` | concept_key: 'fractions.addition.basic', difficulty: 0.6 |
| `SchoolAssessmentFactory` | Random subject/assessment_type/score |

## Docker Services

| Service | Port | Purpose |
|---------|------|---------|
| web | 8081 | Nginx reverse proxy |
| mongo | 27117 | MongoDB 7 |
| redis | 6380 | Redis 7 (sessions/queues) |
| minio | 9002/9003 | S3-compatible storage |
