# Learny Backend

Laravel API backend for the AI School Learning App. This repository uses MongoDB as the primary database, Redis for queues/cache, and MinIO (S3-compatible) for document storage.

## Quick Start
From the repo root:
```bash
docker compose up -d --build
```

Useful commands:
```bash
docker compose run --rm app php artisan test
docker compose run --rm app php artisan queue:work
```

## API Patterns & Conventions
- **Versioned API**: All endpoints are under `/api/v1`.
- **JWT Auth**: Guard `api` uses JWT (`php-open-source-saver/jwt-auth`).
  - Auth routes: `/api/v1/auth/*`
  - Protect routes with `auth:api` middleware.
- **MongoDB Models**: Use `MongoDB\Laravel\Eloquent\Model` and store string IDs in relations.
  - Example: `child_profiles.user_id` stores the parent’s `_id` as a string.
- **Child Scoping**: All child resources are scoped by `child_profile_id` + authenticated `user_id`.
- **Health Check**: `GET /api/health` validates MongoDB, Redis, and S3.

### Example Requests
Register:
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Parent","email":"parent@example.com","password":"secret123","password_confirmation":"secret123"}'
```

Login:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"parent@example.com","password":"secret123"}'
```

Create child profile:
```bash
curl -X POST http://localhost:8080/api/v1/children \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Alex","grade_level":"6th","birth_year":2013}'
```

Upload document:
```bash
curl -X POST http://localhost:8080/api/v1/children/<child_id>/documents \
  -H "Authorization: Bearer <token>" \
  -F "file=@/path/to/worksheet.pdf"
```

## Document Pipeline
- Upload via `POST /api/v1/children/{child}/documents` (multipart `file`).
- Files are stored on the default disk (S3/MinIO).
- OCR is queued via `ProcessDocumentOcr`.
- OCR client abstraction:
  - Interface: `app/Services/Ocr/OcrClientInterface.php`
  - Default implementation: `StubOcrClient` (placeholder)
  - Swap by binding a real client in the container.

## Data Models (MongoDB)
- `users`
- `child_profiles`
- `documents`
- `mastery_profiles`

## Testing Patterns
- Tests run against MongoDB (`learny_test`) and Redis with `QUEUE_CONNECTION=sync`.
- Collections are dropped between tests in `tests/TestCase.php`.
- Factories provide realistic fixtures:
  - `ChildProfileFactory`, `DocumentFactory`, `MasteryProfileFactory`
- OCR job is tested with a mocked OCR client in `OcrJobTest`.

Run tests:
```bash
docker compose run --rm app php artisan test
```

## Seeding
Test seed data lives in:
- `database/seeders/TestSeeder.php`

Run it:
```bash
docker compose run --rm app php artisan db:seed --class=TestSeeder
```

## Environment Variables
Required for local/dev:
- `APP_URL` (default `http://localhost:8080`)
- `DB_CONNECTION=mongodb`
- `DB_HOST=mongo`
- `DB_PORT=27017`
- `DB_DATABASE=learny`
- `DB_AUTH_DATABASE=admin`
- `REDIS_HOST=redis`
- `QUEUE_CONNECTION=redis`
- `CACHE_STORE=redis`
- `SESSION_DRIVER=redis`
- `JWT_SECRET` (use `php artisan jwt:secret`)
- `FILESYSTEM_DISK=s3`
- `AWS_ACCESS_KEY_ID=minio`
- `AWS_SECRET_ACCESS_KEY=minio12345`
- `AWS_DEFAULT_REGION=us-east-1`
- `AWS_BUCKET=learny`
- `AWS_ENDPOINT=http://minio:9000`
- `AWS_URL=http://localhost:9002/learny`
- `AWS_USE_PATH_STYLE_ENDPOINT=true`
- `MISTRAL_API_KEY`
- `MISTRAL_URL=https://api.mistral.ai/v1`
- `MISTRAL_OCR_MODEL=mistral-ocr-latest`

Testing overrides live in `phpunit.xml` (Mongo `learny_test`, array cache/session, sync queue).

## Architecture Notes
- **Auth**: JWT guard for stateless mobile clients.
- **Data**: MongoDB stores parent, child, mastery, and document metadata.
- **Storage**: MinIO (S3 API) holds uploaded files; metadata stored in MongoDB.
- **Processing**: OCR runs via queue jobs; swap `OcrClientInterface` binding for real OCR.

## Next Milestones (Backend)
- **OCR pipeline**: Replace `StubOcrClient` with a real OCR service and store extracted text + confidence.
- **Concept extraction**: Add services and jobs to extract concepts from OCR text.
- **Learning packs**: Introduce `learning_packs` and `games` collections with JSON schema validation.
- **Attempts & mastery**: Persist game attempts and update mastery in a queue-driven flow.
- **Progress dashboards**: Add parent analytics endpoints (strengths/weaknesses, trends).
- **Security hardening**: Enforce per-child access on all new endpoints, add rate limits.

## OpenAPI (Minimal)
```yaml
openapi: 3.0.3
info:
  title: Learny API
  version: 0.1.0
servers:
  - url: http://localhost:8080/api/v1
paths:
  /auth/register:
    post:
      summary: Register parent account
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [name, email, password, password_confirmation]
              properties:
                name: { type: string }
                email: { type: string, format: email }
                password: { type: string, minLength: 8 }
                password_confirmation: { type: string, minLength: 8 }
      responses:
        "200": { description: OK }
  /auth/login:
    post:
      summary: Login parent
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, password]
              properties:
                email: { type: string, format: email }
                password: { type: string }
      responses:
        "200": { description: OK }
  /children:
    get:
      summary: List child profiles
      security: [{ bearerAuth: [] }]
      responses:
        "200": { description: OK }
    post:
      summary: Create child profile
      security: [{ bearerAuth: [] }]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [name]
              properties:
                name: { type: string }
                grade_level: { type: string }
                birth_year: { type: integer }
                notes: { type: string }
      responses:
        "201": { description: Created }
  /children/{childId}:
    get:
      summary: Get child profile
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      responses:
        "200": { description: OK }
    patch:
      summary: Update child profile
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                name: { type: string }
                grade_level: { type: string }
                birth_year: { type: integer }
                notes: { type: string }
      responses:
        "200": { description: OK }
    delete:
      summary: Delete child profile
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      responses:
        "200": { description: OK }
  /children/{childId}/mastery:
    get:
      summary: List mastery profiles
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      responses:
        "200": { description: OK }
    post:
      summary: Upsert mastery profile
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [concept_key]
              properties:
                concept_key: { type: string }
                concept_label: { type: string }
                mastery_level: { type: number, format: float }
                total_attempts: { type: integer }
                correct_attempts: { type: integer }
                last_attempt_at: { type: string, format: date-time }
      responses:
        "201": { description: Created }
  /children/{childId}/progress:
    get:
      summary: Get mastery summary
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      responses:
        "200": { description: OK }
  /children/{childId}/documents:
    get:
      summary: List documents
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      responses:
        "200": { description: OK }
    post:
      summary: Upload document
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              required: [file]
              properties:
                file: { type: string, format: binary }
      responses:
        "201": { description: Created }
  /children/{childId}/documents/{documentId}:
    get:
      summary: Get document
      security: [{ bearerAuth: [] }]
      parameters:
        - in: path
          name: childId
          required: true
          schema: { type: string }
        - in: path
          name: documentId
          required: true
          schema: { type: string }
      responses:
        "200": { description: OK }
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

## OCR Provider (Mistral via Prism)
- Set `MISTRAL_API_KEY` in `.env` and configure `MISTRAL_URL` if needed.
- Default model: `MISTRAL_OCR_MODEL=mistral-ocr-latest` (mapped in `config/prism.php`).
- The OCR job uses a signed URL to the stored document. Ensure MinIO S3 signing works.
- The OCR URL must be publicly reachable by Mistral's API (signed URLs are fine).
## Environment Notes
- MinIO runs on `http://localhost:9002` (API) and `http://localhost:9003` (console).
- Ensure bucket `learny` exists before uploading documents.
