
# Technical Specifications — AI School Learning App

## 1. System Architecture

Mobile App (Flutter / React Native)
→ JSON Game Renderer
→ REST API
→ Laravel Backend
→ AI Services
→ MongoDB

---

## 2. Backend Stack

- Laravel
- REST API (JSON only)
- MongoDB (NoSQL)
- Redis / Queue system
- JWT authentication
- Object storage (S3 compatible)

---

## 3. Mobile Application

- Flutter or React Native
- JSON-driven UI rendering
- Stateless mini-games
- Local cache for offline usage
- Answer & analytics sync

---

## 4. Core Data Models

- Users
- Documents
- Concepts
- Learning Packs
- Games
- Attempts / Game Results
- Mastery Profiles

---

## 5. AI Processing Pipeline

1. OCR & document parsing
2. Concept extraction
3. Difficulty estimation
4. Learning pack generation
5. Mini-game content generation
6. JSON schema validation
7. Result capture for personalization feedback loops

---

## 6. Game Engine Principles

- Backend generates declarative JSON
- Mobile app renders widgets only
- No business logic on the client
- Easy extension via new game schemas

---

## 7. Non-Functional Requirements

- Asynchronous AI processing
- Strict JSON validation
- Secure document access (per child)
- Scalable architecture
- Observability and logging

---

## 8. Snap-to-Quiz Evolution Checklist

- Schema & context design
  - Define extended learning pack fields (language, difficulty, topics, engagement metadata).
  - Define extended quiz fields (title/intro, hints, explanations, per-question metadata).
  - Confirm new game types: true/false, fill-in-the-blank, ordering, multiple-select, short-answer.
  - Define context payload from app (subject, grade, language, learning goal, short context text).
- Backend updates
  - Accept context fields in `DocumentController@store`.
  - Persist context on `Document` and/or `LearningPack`.
  - Update generation prompts to incorporate context and language requirements.
  - Extend JSON schemas + validators for new fields and game types.
- App updates
  - Add context step in scan/upload flow (subject + short description).
  - Send context with upload.
  - Render new game types and show hints/explanations/intro.
- Testing
  - End-to-end test of snap → upload → generate → quiz.
  - Validate schemas with new fields.
  - Verify output language matches input material/context.
