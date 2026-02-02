# Product Roadmap — AI School Learning App

## Overview
This roadmap translates the business and technical specifications into a phased delivery plan. It prioritizes an MVP focused on short, ethical, AI-assisted learning sessions for children (10–14) and a scalable backend pipeline that can generate JSON-driven mini-games.

## Phase 0 — Foundations (Project Setup)
**Goal:** Establish architecture, tooling, and core data models.
- Choose mobile stack (Flutter) and confirm JSON renderer approach.
- Set up Laravel API skeleton with JWT auth, MongoDB, Redis/queue, and S3-compatible storage.
- Define data models: Users, Documents, Concepts, Learning Packs, Games, Attempts, Mastery Profiles.
- Establish JSON schema validation and API contract conventions.
**Exit criteria:** End-to-end “hello world” game payload renders on device from backend.

## Phase 1 — MVP Learning Flow
**Goal:** Deliver the core parent/child journeys and learning packs.
- Parent & child accounts, child profile management.
- Document upload (photo/PDF) with secure per-child access.
- AI pipeline v1: OCR → concept extraction → learning pack generation.
- MVP mini-games: flashcards, quizzes, matching (stateless JSON).
- Revision Express mode for quick pre-test review.
**Exit criteria:** A child can upload material, complete a 3–10 minute session, and receive feedback.

## Phase 2 — Personalization & Mastery
**Goal:** Adapt learning paths and measure mastery.
- Mastery profile updates per concept based on attempts.
- Adaptive difficulty and content sequencing.
- Analytics sync and offline cache for mobile.
- Parent progress view (strengths/weaknesses, mastery trends).
**Exit criteria:** Learning packs adjust based on prior performance and show measurable mastery gains.

## Phase 3 — Scale, Reliability, and Expansion
**Goal:** Harden the system and expand content formats.
- Queue-based AI processing with observability and retry policies.
- Strong JSON validation, schema versioning, and backward compatibility.
- Additional mini-game schemas and richer learning interactions.
- Performance tuning for large documents and concurrent users.
**Exit criteria:** Stable processing at scale, resilient pipelines, and extensible game formats.

## Execution Plan (Epics & User Stories)
### Epic A — Platform Foundations
**Goal:** A stable Flutter app and Laravel backend that can exchange JSON game payloads.
- Story A1: As a developer, I can bootstrap a Flutter app with a JSON-rendered game shell.
- Story A2: As a developer, I can authenticate via JWT and call a protected API endpoint.
- Story A3: As a system, I validate JSON game schemas and return clear errors to clients.

### Epic B — Accounts & Profiles
**Goal:** Parent and child profiles with secure access.
- Story B1: As a parent, I can create an account and log in.
- Story B2: As a parent, I can create and manage child profiles.
- Story B3: As a system, I enforce per-child access to documents and learning data.

### Epic C — Document Intake & AI Pipeline v1
**Goal:** Turn school material into learning packs.
- Story C1: As a parent, I can upload photos or PDFs of school material.
- Story C2: As a system, I run OCR and extract concepts from uploaded material.
- Story C3: As a system, I generate a learning pack and store it for a child.

### Epic D — Mini-Games (MVP)
**Goal:** Deliver short, engaging learning sessions.
- Story D1: As a child, I can review flashcards generated from my material.
- Story D2: As a child, I can complete quizzes and see immediate feedback.
- Story D3: As a child, I can play matching games based on my learning pack.

### Epic E — Revision Express
**Goal:** Quick review before tests.
- Story E1: As a child, I can start a 3–10 minute Revision Express session.
- Story E2: As a system, I prioritize weak concepts in Revision Express.

### Epic F — Mastery & Personalization
**Goal:** Track mastery and adapt content.
- Story F1: As a system, I record attempts and update mastery per concept.
- Story F2: As a child, I receive learning packs adapted to my difficulty level.
- Story F3: As a parent, I can view mastery trends and weak areas.

### Epic G — Reliability & Scale
**Goal:** Stable processing and observability.
- Story G1: As a system, I process AI jobs asynchronously with retries.
- Story G2: As a system, I log pipeline stages and error rates for monitoring.
- Story G3: As a user, I see clear processing status for uploads.

## Complete User Story List
- A1: Bootstrap Flutter app with JSON-rendered game shell.
- A2: JWT authentication and protected API access.
- A3: JSON schema validation with clear errors.
- B1: Parent account creation and login.
- B2: Parent manages child profiles.
- B3: Enforce per-child access to documents and learning data.
- C1: Parent uploads photos or PDFs.
- C2: OCR and concept extraction from uploaded material.
- C3: Generate and store learning packs per child.
- D1: Child reviews AI-generated flashcards.
- D2: Child completes quizzes with immediate feedback.
- D3: Child plays matching games from learning packs.
- E1: Child starts a 3–10 minute Revision Express session.
- E2: Revision Express prioritizes weak concepts.
- F1: Record attempts and update mastery per concept.
- F2: Adaptive learning packs based on difficulty.
- F3: Parent views mastery trends and weak areas.
- G1: Async AI jobs with retries.
- G2: Pipeline logging and monitoring.
- G3: User-visible processing status.

## Dependencies (User Story Graph)
- A1 → A2 (app shell needed to exercise auth flows)
- A2 → B1 (authentication required for account creation/login)
- A2 → B2 (authenticated parent needed for child profile management)
- B2 → B3 (child profiles are required to scope access controls)
- B3 → C1 (uploads must be tied to a child profile)
- C1 → C2 (OCR requires uploaded material)
- C2 → C3 (learning packs depend on extracted concepts)
- A3 → D1, D2, D3 (game payloads must validate against schema)
- C3 → D1, D2, D3 (games require learning packs)
- D1/D2/D3 → E1 (Revision Express uses existing game content)
- F1 → F2 (adaptive sequencing requires mastery data)
- F1 → F3 (parent views need mastery data)
- C3 → F1 (attempts are tied to learning pack concepts)
- C1/C2/C3 → G1 (AI pipeline needs async processing)
- G1 → G2 (monitoring for async pipeline)
- G1 → G3 (status reporting relies on queued job state)

## Sprint-Ready Story Order
**Foundations (Phase 0):** A1 → A2 → A3  
**MVP Flow (Phase 1):** B1 → B2 → B3 → C1 → C2 → C3 → D1 → D2 → D3 → E1 → E2  
**Personalization (Phase 2):** F1 → F2 → F3  
**Scale (Phase 3):** G1 → G2 → G3

## Phase-to-Story Mapping
**Phase 0 — Foundations:** A1, A2, A3  
**Phase 1 — MVP Learning Flow:** B1, B2, B3, C1, C2, C3, D1, D2, D3, E1, E2  
**Phase 2 — Personalization & Mastery:** F1, F2, F3  
**Phase 3 — Scale, Reliability, and Expansion:** G1, G2, G3

## Phase 1 Sprint Breakdown
**Sprint 1 — Core Access & Ingestion (Milestone: first learning pack generated)**  
Focus: B1, B2, B3, C1, C2  
Deliverable: Parent/child accounts, secure uploads, OCR + concept extraction running end-to-end.

**Sprint 2 — Learning Sessions (Milestone: complete MVP learning flow)**  
Focus: C3, D1, D2, D3, E1, E2  
Deliverable: Learning pack generation, MVP mini-games, and Revision Express session on device.

## Key Risks & Mitigations
- **AI quality/accuracy:** Human-in-the-loop review tools, schema validation, and difficulty calibration.
- **Latency:** Async processing with clear user status and notifications.
- **Child safety/privacy:** Strict access control, minimal data retention, and secure storage policies.

## Success Metrics (Aligned to KPIs)
- Weekly active learners, session completion rate.
- Retention (D7/D30).
- Mastery progression per concept and reduced repeat mistakes.
