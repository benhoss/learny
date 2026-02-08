# Detailed Specification — School Results Hub

## 1. Context
This specification details implementation of UX Improvement #2 from `specs/ux_improvements.md`: **School Results Hub (grades, tests, trend lines)**.

Goal: allow parents to track school assessments and connect outcomes with app activity/mastery.

## 2. Product Goals
- Give parents school-aligned performance visibility.
- Support fast entry of assessments (manual first, OCR-compatible source flag).
- Enable trend analysis by subject over recent weeks.

## 3. Data Model
`school_assessments` collection fields:
- `child_profile_id` (string, required)
- `subject` (string, required, max 100)
- `assessment_type` (string, required, max 80)
- `score` (number, required)
- `max_score` (number, required)
- `grade` (string, optional, max 20)
- `assessed_at` (datetime, required)
- `teacher_note` (string, optional, max 500)
- `source` (`manual|ocr`, optional, default `manual`)
- derived `score_percent` (response-only)

Validation constraints:
- `score <= max_score`
- `max_score >= 1`
- child ownership enforced on every endpoint.

## 4. API Contract
All routes scoped by child and JWT auth:
- `GET /api/v1/children/{child}/school-assessments`
- `POST /api/v1/children/{child}/school-assessments`
- `PATCH /api/v1/children/{child}/school-assessments/{assessment}`
- `DELETE /api/v1/children/{child}/school-assessments/{assessment}`

Response shape:
```json
{
  "data": {
    "_id": "...",
    "subject": "Math",
    "assessment_type": "weekly_test",
    "score": 16,
    "max_score": 20,
    "score_percent": 80.0,
    "source": "manual"
  }
}
```

## 5. Mobile Integration
`BackendClient` exposes:
- `listSchoolAssessments`
- `createSchoolAssessment`
- `updateSchoolAssessment`
- `deleteSchoolAssessment`

A dedicated `SchoolAssessment` model maps API payloads and supports local rendering.

## 6. Testing
Feature coverage must include:
- CRUD happy path for owned child.
- score/max validation guard (`score > max_score` rejected).
- access control (parent cannot read another parent’s child assessments).

## 7. Rollout Notes
- Ship with manual entry first (`source=manual`).
- OCR ingestion can reuse same endpoint with `source=ocr` once extraction pipeline is ready.
- Trend-line dashboard visualizations can consume this domain without schema changes.
