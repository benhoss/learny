# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Learny is an AI-powered learning app for children (ages 10-14). Parents upload school materials (photos/PDFs), the backend processes them through an AI pipeline (OCR → concept extraction → learning pack generation), and children play mini-games (flashcards, quizzes, matching) to learn concepts.

## Repository Structure

```
backend/          # Laravel 12 API (PHP 8.2+, MongoDB, Redis, MinIO/S3)
mobile/learny_app/  # Flutter mobile app
website/          # Marketing website (React + Vite + Tailwind)
specs/            # Business and technical specifications
```

## Development Commands

### Backend (Laravel)

```bash
# Start all services (from repo root)
docker compose up -d --build

# Run tests
docker compose run --rm app php artisan test

# Run single test file
docker compose run --rm app php artisan test --filter=AuthFlowTest

# Run queue worker
docker compose run --rm app php artisan queue:work

# Seed test data
docker compose run --rm app php artisan db:seed --class=TestSeeder

# Lint with Laravel Pint
docker compose run --rm app ./vendor/bin/pint
```

### Flutter App

```bash
cd mobile/learny_app

# Install dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Run single test file
flutter test test/widget_test.dart
```

### Website

```bash
cd website
npm install
npm run dev    # Development server
npm run build  # Production build
```

## Architecture

### Backend Services

- **Auth**: JWT authentication (`php-open-source-saver/jwt-auth`). All protected routes use `auth:api` middleware.
- **Database**: MongoDB via `mongodb/laravel-mongodb`. Models extend `MongoDB\Laravel\Eloquent\Model`.
- **Storage**: MinIO (S3-compatible) for document uploads. Bucket: `learny`.
- **AI Pipeline**: Prism PHP (`prism-php/prism`) for LLM calls. Mistral for OCR.

### AI Processing Pipeline (Jobs)

1. `ProcessDocumentOcr` - Extracts text from uploaded documents
2. `ExtractConceptsFromDocument` - Identifies learning concepts from OCR text
3. `GenerateLearningPackFromDocument` - Creates learning pack with structured content
4. `GenerateGamesFromLearningPack` - Generates game JSON (flashcards, quizzes, matching)

### Key Service Interfaces

- `OcrClientInterface` - OCR abstraction (impl: `PrismOcrClient`, `StubOcrClient`)
- `LearningPackGeneratorInterface` - Learning pack generation (impl: `PrismLearningPackGenerator`)
- `GameGeneratorInterface` - Game content generation (impl: `PrismGameGenerator`)

### API Routes

All API endpoints are versioned under `/api/v1`. Key resource patterns:
- `/api/v1/auth/*` - Authentication (register, login, logout, refresh)
- `/api/v1/children` - Child profiles (CRUD)
- `/api/v1/children/{child}/documents` - Document upload and management
- `/api/v1/children/{child}/learning-packs` - Generated learning packs
- `/api/v1/children/{child}/learning-packs/{pack}/games` - Game content and results

### Flutter App Structure

- `lib/app/` - App configuration and entry point
- `lib/models/` - Data models (learning packs, quiz questions, etc.)
- `lib/screens/` - Screen widgets organized by feature (auth, games, documents, etc.)
- `lib/services/backend_client.dart` - API client
- `lib/state/app_state.dart` - Application state management
- `lib/widgets/games/` - Reusable game UI components

## Testing

### Backend
- Tests run against `learny_test` MongoDB database with `QUEUE_CONNECTION=sync`
- Collections are cleared between tests in `tests/TestCase.php`
- Use factories: `ChildProfileFactory`, `DocumentFactory`, `MasteryProfileFactory`

### Flutter
- Golden tests in `test/goldens/`
- Widget tests in `test/`

## Environment

### Docker Services
- `web`: Nginx on port 8081
- `mongo`: MongoDB 7 on port 27117
- `redis`: Redis 7 on port 6379
- `minio`: MinIO S3 on port 9002 (API), 9003 (console)

### Required Environment Variables (backend/.env)
- `JWT_SECRET` - Generate with `php artisan jwt:secret`
- `MISTRAL_API_KEY` - For OCR and AI generation
- S3/MinIO credentials (see `backend/.env.example`)

## Data Models (MongoDB)

- `users` - Parent accounts
- `child_profiles` - Child profiles scoped to parent
- `documents` - Uploaded school materials with OCR status
- `learning_packs` - Generated learning content from documents
- `games` - JSON game schemas (flashcards, quizzes, matching)
- `game_results` - Player attempts and scores
- `mastery_profiles` - Per-concept mastery tracking
