# Learny Flutter App — Architecture Reference

## Directory Structure

```
mobile/learny_app/lib/
├── main.dart                          # Entry point
├── app/
│   ├── app.dart                       # MaterialApp, routes, localization delegates
│   └── backend_config.dart            # Base URL, demo credentials, feature flags
├── models/                            # 18 data models
├── screens/                           # ~50 screen files in 12 feature dirs
│   ├── auth/                          # login, signup, forgot_password, verify_email
│   ├── home/                          # home_shell (bottom nav), home_screen, notifications
│   ├── onboarding/                    # welcome, how_it_works, create_profile, consent, plan
│   ├── documents/                     # upload, camera_capture, review, processing, library
│   ├── games/                         # quiz_setup, quiz, flashcards, matching, results
│   ├── packs/                         # packs_list, pack_detail, pack_session
│   ├── progress/                      # progress_overview, mastery_detail, achievements, streaks
│   ├── parent/                        # dashboard, child_selector, weekly, weak_areas, pin, settings
│   ├── revision/                      # revision_setup, revision_session, revision_results
│   ├── account/                       # account_settings, subscription, upgrade_plan, delete_account
│   ├── support/                       # faq, contact_support, safety_privacy
│   ├── system/                        # empty_state, error_state, offline
│   └── shared/                        # gradient_scaffold, placeholder_screen
├── widgets/
│   ├── games/                         # GameScaffold, GameHeader, GameCard, AnswerChip,
│   │                                  # FeedbackBanner, PressableScale, MasteryMeter,
│   │                                  # ProgressBar, ResultSummaryCard, StreakPill, TimerBadge
│   └── animations/                    # FadeInSlide, FlipCard, ScreenTransition, animations
├── services/
│   ├── backend_client.dart            # HTTP API client (~814 lines)
│   └── haptic_service.dart            # Semantic haptic feedback
├── state/
│   ├── app_state.dart                 # ChangeNotifier (~2650 lines)
│   └── app_state_scope.dart           # InheritedNotifier wrapper
├── routes/
│   └── app_routes.dart                # 54 static route constants
├── theme/
│   ├── app_theme.dart                 # LearnyColors, LearnyTheme.light()
│   ├── app_tokens.dart                # Spacing, radius, shadows, gradients (context extension)
│   └── app_assets.dart                # AppImages asset paths
└── l10n/
    ├── app_en.arb                     # English (template)
    ├── app_fr.arb                     # French
    ├── app_nl.arb                     # Dutch
    └── generated/                     # Auto-generated L10n classes
```

## Data Models

### ChildProfile
```dart
String id, name, gradeLabel, preferredLanguage
int? age
String? schoolClass, gender
List<Map>? learningStylePreferences, confidenceBySubject
Map<String, dynamic>? supportNeeds
// fromJson() handles _id as string or {$oid: ...}
```

### UserProfile
```dart
String id, name, avatarAsset, gradeLabel, planName
// copyWith() for immutable updates
```

### LearningPack
```dart
String id, title, subject
int itemCount, minutes, conceptsMastered, conceptsTotal
double progress  // 0.0–1.0
IconData icon; Color color  // UI display, from _packStyleForSubject()
List<String> conceptKeys
// copyWith()
```

### QuizSession
```dart
String packId
String? backendSessionId
List<QuizQuestion> questions
List<int> questionIndices
int requestedQuestionCount
// Mutable: currentIndex, correctCount, incorrectIndices, results
// isComplete getter
```

### QuizQuestion
```dart
String id, prompt, topic
List<String> options
int correctIndex
String? hint, explanation, answerText
List<int>? correctIndices
List<String>? acceptedAnswers, orderedSequence
// Getters: isMultiSelect, isTextInput, isOrdering
```

### RevisionSession
```dart
String backendSessionId, subjectLabel
int durationMinutes
List<RevisionPrompt> prompts
// Mutable: currentIndex, correctCount
```

### DocumentItem
```dart
String id, title, subject, statusLabel
DateTime createdAt
// copyWith()
```

### ActivityItem
```dart
String id, gameType, subject, cheerMessage
DateTime completedAt
int scorePercent, correctAnswers, totalQuestions, xpEarned
String? packId, packTitle, documentId, documentTitle
double? progressionDelta
List<String> availableGameTypes, remainingGameTypes
// fromJson() with defaults
```

### SchoolAssessment
```dart
String id, subject, assessmentType
int score, maxScore
DateTime assessedAt
String? grade, teacherNote, source
double scorePercent  // computed
// fromJson()
```

### Simple Models
- **ParentProfile**: name, email
- **Achievement**: id, title, description, icon (IconData), isUnlocked
- **WeakArea**: title, note
- **WeeklySummary**: minutesSpent, newBadges, sessionsCompleted, topSubject
- **DailyLearningTime**: dayLabel, minutes
- **NotificationItem**: id, title, message, timeLabel, isRead (copyWith)
- **PlanOption**: id, name, priceLabel, description, isHighlighted
- **FaqItem**: question, answer

## Route Map

```dart
// Onboarding
welcome = '/'
howItWorks = '/how-it-works'
createProfile = '/create-profile'
consent = '/consent'
plan = '/plan'

// Auth
signup = '/signup'
login = '/login'
forgotPassword = '/forgot-password'
verifyEmail = '/verify-email'

// Core
home = '/home'
notifications = '/notifications'

// Documents
cameraCapture = '/camera-capture'
upload = '/upload'
review = '/review'
processing = '/processing'
library = '/library'

// Packs
packsList = '/packs'
packDetail = '/pack-detail'
packSession = '/pack-session'

// Games
quizSetup = '/quiz-setup'
quiz = '/quiz'
flashcards = '/flashcards'
matching = '/matching'
results = '/results'

// Revision
revisionSetup = '/revision-setup'
revisionSession = '/revision-session'
revisionResults = '/revision-results'

// Progress
progressOverview = '/progress-overview'
masteryDetail = '/mastery-detail'
streaksRewards = '/streaks-rewards'
achievements = '/achievements'

// Parent
parentDashboard = '/parent-dashboard'
childSelector = '/child-selector'
weeklySummary = '/weekly-summary'
weakAreas = '/weak-areas'
learningTime = '/learning-time'
parentPin = '/parent-pin'
parentSettings = '/parent-settings'

// Support
safetyPrivacy = '/safety-privacy'
faq = '/faq'
contactSupport = '/contact-support'

// Account
subscription = '/subscription'
upgradePlan = '/upgrade-plan'
accountSettings = '/account-settings'
deleteAccount = '/delete-account'

// System
emptyState = '/empty-state'
errorState = '/error-state'
offline = '/offline'
```

## BackendClient API Methods

### Auth
| Method | HTTP | Endpoint |
|--------|------|----------|
| `login(email, password)` | POST | `/api/v1/auth/login` |
| `register(name, email, password)` | POST | `/api/v1/auth/register` |

### Children
| Method | HTTP | Endpoint |
|--------|------|----------|
| `listChildren()` | GET | `/api/v1/children` |
| `createChild(name, ...)` | POST | `/api/v1/children` |

### Documents
| Method | HTTP | Endpoint |
|--------|------|----------|
| `uploadDocument(childId, bytes, filename, ...)` | POST | `/api/v1/children/{child}/documents` |
| `uploadDocumentBatch(childId, files[], ...)` | POST | `/api/v1/children/{child}/documents` |
| `listDocuments(childId)` | GET | `/api/v1/children/{child}/documents` |
| `getDocument(childId, docId)` | GET | `/api/v1/children/{child}/documents/{doc}` |
| `regenerateDocument(childId, docId, gameTypes?)` | POST | `/api/v1/children/{child}/documents/{doc}/regenerate` |
| `suggestDocumentMetadata(childId, bytes, filename)` | POST | `/api/v1/children/{child}/documents/suggest-metadata` |

### Learning Packs & Games
| Method | HTTP | Endpoint |
|--------|------|----------|
| `listLearningPacks(childId, documentId?)` | GET | `/api/v1/children/{child}/learning-packs` |
| `listGames(childId, packId)` | GET | `/api/v1/children/{child}/learning-packs/{pack}/games` |
| `submitGameResult(childId, packId, gameId, ...)` | POST | `/api/v1/children/{child}/learning-packs/{pack}/games/{game}/results` |
| `createRetryGame(childId, packId, gameId, ...)` | POST | `/api/v1/children/{child}/learning-packs/{pack}/games/{game}/retry` |

### Quiz Sessions
| Method | HTTP | Endpoint |
|--------|------|----------|
| `createQuizSession(childId, packId, gameId, count)` | POST | `/api/v1/children/{child}/quiz-sessions` |
| `fetchActiveQuizSession(childId, packId, gameId)` | GET | `/api/v1/children/{child}/quiz-sessions/active` |
| `updateQuizSession(childId, sessionId, ...)` | PATCH | `/api/v1/children/{child}/quiz-sessions/{session}` |

### Revision
| Method | HTTP | Endpoint |
|--------|------|----------|
| `startRevisionSession(childId, packId?, ...)` | POST | `/api/v1/children/{child}/revision-sessions` |
| `submitRevisionSession(childId, sessionId, ...)` | POST | `/api/v1/children/{child}/revision-sessions/{session}/submit` |
| `fetchReviewQueue(childId)` | GET | `/api/v1/children/{child}/review-queue` |

### Activities
| Method | HTTP | Endpoint |
|--------|------|----------|
| `listActivities(childId, page?, perPage?)` | GET | `/api/v1/children/{child}/activities` |

### School Assessments
| Method | HTTP | Endpoint |
|--------|------|----------|
| `listSchoolAssessments(childId)` | GET | `/api/v1/children/{child}/school-assessments` |
| `createSchoolAssessment(childId, ...)` | POST | `/api/v1/children/{child}/school-assessments` |
| `updateSchoolAssessment(childId, id, ...)` | PUT | `/api/v1/children/{child}/school-assessments/{id}` |
| `deleteSchoolAssessment(childId, id)` | DELETE | `/api/v1/children/{child}/school-assessments/{id}` |

### Recommendations & Memory
| Method | HTTP | Endpoint |
|--------|------|----------|
| `fetchHomeRecommendations(childId)` | GET | `/api/v1/children/{child}/recommendations` |
| `trackRecommendationEvent(childId, ...)` | POST | `/api/v1/children/{child}/recommendations/events` |
| `fetchMemoryPreferences(childId)` | GET | `/api/v1/children/{child}/memory-preferences` |
| `updateMemoryPreferences(childId, ...)` | PUT | `/api/v1/children/{child}/memory-preferences` |
| `clearMemoryScope(childId, scope)` | DELETE | `/api/v1/children/{child}/memory-preferences/{scope}` |

## AppState Key Fields

### User & Child
```
profile: UserProfile
parentProfile: ParentProfile
children: List<ChildProfile>
backendChildId: String?
locale: Locale?
```

### Learning Content
```
packs: List<LearningPack>
mastery: Map<String, double>          // conceptKey → %
selectedPackId: String?
documents: List<DocumentItem>
```

### Quiz / Games
```
quizSession: QuizSession?
gamePayloads: Map<String, Map>        // type → payload
gameIds: Map<String, String>          // type → backend ID
currentGameType: String?
currentGameId: String?
activeQuizSessionData: Map?           // active backend session
lastGameOutcome: GameOutcome?
lastResultSyncError: String?
```

### Pack Sessions
```
inPackSession: bool
packSessionStage: PackSessionStage?   // flashcards | quiz | matching | results
packGameQueue: List<String>
packGameIndex: int
```

### Revision
```
revisionSession: RevisionSession?
```

### Gamification
```
streakDays: int
xpToday: int
totalXp: int
reviewDueCount: int
reviewDueConceptKeys: List<String>
```

### Document Upload
```
pendingImages: List<Uint8List>
pendingImageNames: List<String>
lastDocumentId: String?
```

### Progress & Analytics
```
achievements: List<Achievement>
activities: List<ActivityItem>
weeklySummary: WeeklySummary
weakAreas: List<WeakArea>
learningTimes: List<DailyLearningTime>
homeRecommendations: List<Map>
schoolAssessments: List<SchoolAssessment>
```

## AppState Key Methods

### Initialization
- `selectChild(String childId)` — switch child, clear session state, reload data
- `setLocale(Locale?)` — switch app language
- `_initializeBackendSession()` — demo auto-login + hydrate

### Quiz Flow
- `prepareQuizSetup({String? packId})` — load payload, init session
- `startQuizFromSetup({int questionCount})` — create backend session
- `resumeQuizFromSetup({String? packId})` — restore active session
- `answerCurrentQuestion(int)` — single-select answer
- `answerCurrentQuestionMulti(List<int>)` — multi-select
- `answerCurrentQuestionText(String)` — text input
- `answerCurrentQuestionOrdering(List<String>)` — ordering
- `resetQuiz()` — clear quiz state
- `retryIncorrectQuestions()` — retry wrong answers

### Pack Sessions
- `startPackSession({String? packId})` — init multi-game session
- `advancePackSession(PackSessionStage)` — progress through stages
- `startGameType(String type)` — load game payload
- `advancePackGame()` — next game in queue
- `completeFlashcardsGame(List<Map>)` — record flashcard results
- `completeMatchingGame(List<Map>)` — record matching results

### Revision
- `startRevision({String? packId})` — fetch revision prompts
- `answerRevisionPrompt(int)` — record answer
- `resetRevision()` — clear state

### Document Upload
- `setPendingImage({Uint8List, String})` — single image
- `addPendingImage({Uint8List, String})` — batch add
- `generateQuizFromBytes({...})` / `generateQuizFromImages({...})` — upload + process
- `regenerateDocument(String docId, {List<String>? gameTypes})` — re-generate

### Data Sync
- `_hydrateFromBackend()` — fetch children, packs, docs, assessments
- `_refreshPacksFromBackend()` — sync packs
- `_refreshReviewCount()` — fetch due concepts
- `_refreshHomeRecommendations()` — personalized recommendations
- `refreshDocumentsFromBackend()` — sync documents
- `refreshActivitiesFromBackend()` — paginated activities

## Design Tokens

### Colors (LearnyColors)
| Name | Hex | Usage |
|------|-----|-------|
| `skyPrimary` | #7DD3E8 | Primary blue, buttons, links |
| `skyLight` | #E8F7FA | Light blue backgrounds |
| `mintPrimary` | #8FE5C2 | Success, correct, mint accents |
| `mintLight` | #B8F0D8 | Light mint backgrounds |
| `lavender` | #C5B9E8 | Purple accents |
| `cream` | #FFF8F0 | Scaffold background |
| `coral` | #FF9A8B | Error, incorrect |
| `sunshine` | #FFD97A | Warning, yellow accents |
| `neutralDark` | #2D3748 | Primary text |
| `neutralMedium` | #5A6C7D | Secondary text |
| `neutralLight` | #8B9CAD | Tertiary text |
| `neutralSoft` | #E8EDF2 | Borders, dividers |
| `neutralCream` | #F7F9FC | Card backgrounds |
| `success` | #7DD3C8 | Teal success variant |

### Spacing (LearnyTokens via context.tokens)
| Token | Value |
|-------|-------|
| `spaceXs` | 4 |
| `spaceSm` | 8 |
| `spaceMd` | 16 |
| `spaceLg` | 24 |
| `spaceXl` | 32 |
| `space2xl` | 48 |

### Border Radius
| Token | Value |
|-------|-------|
| `radiusSm` | 8 |
| `radiusMd` | 12 |
| `radiusLg` | 16 |
| `radiusXl` | 24 |
| `radiusFull` | 9999 |

## Game Widgets Reference

| Widget | File | Purpose |
|--------|------|---------|
| `GameScaffold` | `widgets/games/game_scaffold.dart` | Gradient bg + decorative circles wrapper |
| `GameHeader` | `widgets/games/game_header.dart` | Title, progress, timer, streak, mastery |
| `GameCard` | `widgets/games/game_card.dart` | White card for question content |
| `AnswerChip` | `widgets/games/answer_chip.dart` | Selectable answer option |
| `FeedbackBanner` | `widgets/games/feedback_banner.dart` | Correct/incorrect feedback overlay |
| `PressableScale` | `widgets/games/pressable_scale.dart` | Tap scale animation + haptic |
| `MasteryMeter` | `widgets/games/mastery_meter.dart` | Circular mastery progress |
| `ProgressBar` | `widgets/games/progress_bar.dart` | Linear question progress |
| `ResultSummaryCard` | `widgets/games/result_summary_card.dart` | Score, XP, streak summary |
| `StreakPill` | `widgets/games/streak_pill.dart` | Streak day counter |
| `TimerBadge` | `widgets/games/timer_badge.dart` | Countdown timer display |

## Test Files

| File | Purpose | Status |
|------|---------|--------|
| `test/games_widgets_test.dart` | 7 game widget tests | Always pass |
| `test/widget_test.dart` | Animation tests | Pre-existing timer failures |
| `test/goldens/` | Golden visual regression | Manual |
| `test/state/app_state_result_submission_test.dart` | Result submission | — |
| `test/state/app_state_quiz_session_resume_test.dart` | Quiz resume | — |
| `test/state/home_recommendation_view_test.dart` | Recommendations | — |

## Navigation Flows

### Onboarding
```
Welcome → HowItWorks → CreateProfile → Consent → Plan → Signup/Login → Home
```

### Document Upload
```
CameraCapture/Upload → Review → Processing (poll) → GameTypeSelector/Results
```

### Pack Session (multi-game)
```
PackDetail → PackSession → Flashcards → Quiz → Matching → Results → Home
```

### Quiz Flow
```
QuizSetup (count selection) → Quiz (questions) → Results
```

### Revision
```
RevisionSetup → RevisionSession → RevisionResults
```

### Game Result Submission
```
Game screen → state.answerCurrentQuestion*() → session.results.add()
→ _submitGameResults() [2 retries, 2s delay] → update streaks/XP
→ _refreshPacksFromBackend() + refreshActivitiesFromBackend()
→ navigate to Results screen
```
