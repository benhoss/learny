---
title: "feat: Multi-lingual support (EN/FR/NL)"
type: feat
date: 2026-02-08
---

# Multi-lingual Support (EN/FR/NL)

## Overview

Make Learny fully multi-lingual across three layers:
1. **Flutter UI strings** — extract ~120+ hardcoded English strings into ARB files with French and Dutch translations
2. **Backend API response strings** — server-side translation of user-facing strings (revision prompts, recommendation titles, session labels)
3. **AI-generated content** — ensure concept keys remain language-neutral (English kebab-case) while content follows the document's language

Language preference is stored per child profile (`preferred_language` field, already exists). The Flutter app locale follows the active child's `preferred_language`, falling back to device locale.

## Problem Statement / Motivation

Learny targets children in Belgium, a trilingual country (French, Dutch, German + English). Currently:
- All Flutter UI strings are hardcoded in English (~120+ strings across 15+ screens)
- `preferred_language` on `ChildProfile` is stored but never consumed by any service
- Backend services (RevisionComposer, MemorySignalProjector) return hardcoded English strings
- AI pipeline uses `document.language` for content generation but has no concept key language policy
- No Flutter i18n infrastructure exists (no `l10n.yaml`, no ARB files, no `flutter_localizations`)
- The test seeder creates an English-only profile ("Alex, Grade 6")

## Proposed Solution

### Language Resolution Rules

**Flutter UI locale:**
`preferred_language` on active child → device locale → `'en'`

**AI-generated content language:**
`document.language` → detected source text language → `'en'`
(Content follows the document's language, NOT the child's preferred language)

**Concept keys:**
Always English kebab-case (e.g., `quadratic-equations`), regardless of document or content language. Labels/descriptions follow content language.

**Backend API response strings:**
Server-side PHP translation maps keyed by child's `preferred_language`.

### Supported Languages

| Code | Language | Region |
|------|----------|--------|
| `en` | English | Default / fallback |
| `fr` | French | Belgium, France |
| `nl` | Dutch | Belgium, Netherlands |

## Technical Approach

### Phase 1: Flutter i18n Foundation

Set up Flutter's official localization system with ARB files and code generation.

**Files to create:**

- `mobile/learny_app/l10n.yaml` — code generation config
- `mobile/learny_app/lib/l10n/app_en.arb` — English template (source of truth with `@metadata`)
- `mobile/learny_app/lib/l10n/app_fr.arb` — French translations
- `mobile/learny_app/lib/l10n/app_nl.arb` — Dutch translations
- `mobile/learny_app/lib/l10n/generated/` — auto-generated Dart classes (commit to VCS)

**Files to modify:**

- `mobile/learny_app/pubspec.yaml` — add `flutter_localizations` SDK dep, `intl: any`, set `generate: true`
- `mobile/learny_app/lib/app/app.dart` — add `localizationsDelegates`, `supportedLocales`, `locale` bound to `AppState.locale`
- `mobile/learny_app/lib/state/app_state.dart` — add `Locale? _locale` field, `setLocale()`, derive from active child's `preferredLanguage`
- `mobile/learny_app/ios/Runner/Info.plist` — add `CFBundleLocalizations` for `en`, `fr`, `nl`

**l10n.yaml configuration:**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: L10n
synthetic-package: false
output-dir: lib/l10n/generated
preferred-supported-locales:
  - en
  - fr
  - nl
nullable-getter: false
required-resource-attributes: true
```

**Key pattern — accessing translations:**

```dart
final l10n = L10n.of(context);
Text(l10n.welcomeTitle)           // simple string
Text(l10n.packCount(5))           // plural: "5 learning packs"
Text(l10n.quizScore(8, 10))       // interpolation: "You scored 8 out of 10"
```

**Key pattern — locale reactivity:**

```dart
// In app.dart MaterialApp:
locale: appState.locale,
localizationsDelegates: L10n.localizationsDelegates,
supportedLocales: L10n.supportedLocales,

// In AppState, when selecting a child:
void selectChild(ChildProfile child) {
  _activeChild = child;
  if (child.preferredLanguage != null) {
    _locale = Locale(child.preferredLanguage!);
  }
  notifyListeners();  // rebuilds MaterialApp with new locale
}
```

**Important — Flutter 3.38 breaking change:** `synthetic-package: false` is required. The old `package:flutter_gen` import path no longer works. Import from `lib/l10n/generated/` directly.

### Phase 2: Extract Flutter UI Strings

Extract all hardcoded English strings into ARB files. Organized by feature prefix in a single ARB file per locale.

**Key naming convention:** `{feature}{Screen}{Element}` in camelCase.

**Screens to extract (with approximate string counts):**

| Screen / Widget | File | Approx. strings |
|---|---|---|
| Home screen | `lib/screens/home/home_screen.dart` | ~25 |
| Quiz screen | `lib/screens/games/quiz_screen.dart` | ~20 |
| Flashcards screen | `lib/screens/games/flashcards_screen.dart` | ~12 |
| Matching screen | `lib/screens/games/matching_screen.dart` | ~8 |
| Results screen | `lib/screens/games/results_screen.dart` | ~10 |
| Processing screen | `lib/screens/documents/processing_screen.dart` | ~20 (incl. 15 fun facts) |
| Upload screen | `lib/screens/documents/upload_screen.dart` | ~12 |
| Create profile screen | `lib/screens/onboarding/create_profile_screen.dart` | ~5 |
| Feedback banner | `lib/widgets/games/feedback_banner.dart` | ~3 |
| Result summary card | `lib/widgets/games/result_summary_card.dart` | ~5 |
| AppState status messages | `lib/state/app_state.dart` | ~15 |

**Strings requiring ICU plural syntax:**

```json
{
  "gameDueConceptCount": "{count, plural, =0{No concepts to review} =1{1 concept to review} other{{count} concepts to review}}",
  "gameCardProgress": "Card {current} of {total}",
  "gameQuestionProgress": "Question {current} of {total}",
  "resultCorrectCount": "{correct} of {total} correct",
  "streakDays": "{count, plural, =1{1 day} other{{count} days}}"
}
```

**True/False game labels** — currently hardcoded in `AppState._loadQuizFromPayload()` at line 1348:

```dart
// Before:
options: const ['True', 'False'],

// After:
// Pass localized strings from the widget layer, or use L10n in AppState
// Since AppState doesn't have BuildContext, store the labels on QuizQuestion
// and populate them in the widget that has context.
```

**Day-of-week labels** — `AppState._emptyLearningTimes()` line 287-296:

```dart
// Before: hardcoded 'Mon', 'Tue', etc.
// After: use DateFormat('E', locale).format(date) from intl package
```

### Phase 3: Backend Server-Side Translation

Add a lightweight translation layer for backend strings returned in API responses.

**Files to create:**

- `backend/app/Support/Translator.php` — simple translation helper

**Files to modify:**

- `backend/app/Services/Revision/RevisionComposer.php` — translate prompt strings
- `backend/app/Services/Memory/MemorySignalProjector.php` — translate recommendation titles/subtitles
- `backend/app/Http/Controllers/Api/RevisionSessionController.php` — translate session labels

**Translation helper pattern:**

```php
// backend/app/Support/Translator.php
namespace App\Support;

class Translator
{
    private const TRANSLATIONS = [
        'en' => [
            'revision.review_prompt' => 'Which concept should you review now?',
            'revision.not_sure' => 'Not sure yet',
            'revision.due_now' => 'Due now in your review queue',
            'revision.recent_mistake' => 'Based on a recent wrong answer',
            'revision.recent_upload' => 'From your latest uploaded document',
            'revision.pick_concept' => 'Pick the concept from your recent upload.',
            'revision.quick_revision' => 'Quick Revision',
            'recommendation.review_now' => 'Review now: :label',
            'recommendation.due_revision' => 'This concept is due for spaced revision.',
            'recommendation.weak_area' => 'Practice weak area',
            'recommendation.continue_upload' => 'Continue latest upload',
            'recommendation.streak_rescue' => 'Streak rescue session',
            'recommendation.streak_subtitle' => 'Keep your streak alive with a 2-minute quick review.',
            'recommendation.quick_practice' => 'Start a quick practice',
            'recommendation.memory_paused' => 'Personalization is paused. You can still learn from uploads.',
        ],
        'fr' => [
            'revision.review_prompt' => 'Quel concept devrais-tu revoir maintenant ?',
            'revision.not_sure' => 'Pas encore sur',
            'revision.due_now' => 'A revoir maintenant',
            'revision.recent_mistake' => 'Suite a une erreur recente',
            'revision.recent_upload' => 'De ton dernier document',
            'revision.pick_concept' => 'Choisis le concept de ton dernier document.',
            'revision.quick_revision' => 'Revision rapide',
            'recommendation.review_now' => 'A revoir : :label',
            'recommendation.due_revision' => 'Ce concept est a revoir selon ton planning.',
            'recommendation.weak_area' => 'Renforcer un point faible',
            'recommendation.continue_upload' => 'Continuer le dernier document',
            'recommendation.streak_rescue' => 'Session de sauvetage de serie',
            'recommendation.streak_subtitle' => 'Garde ta serie avec une revision de 2 minutes.',
            'recommendation.quick_practice' => 'Lancer un exercice rapide',
            'recommendation.memory_paused' => 'La personnalisation est en pause. Tu peux quand meme apprendre.',
        ],
        'nl' => [
            'revision.review_prompt' => 'Welk concept moet je nu herhalen?',
            'revision.not_sure' => 'Nog niet zeker',
            'revision.due_now' => 'Nu te herhalen',
            'revision.recent_mistake' => 'Na een recent fout antwoord',
            'revision.recent_upload' => 'Van je laatste document',
            'revision.pick_concept' => 'Kies het concept van je laatste document.',
            'revision.quick_revision' => 'Snelle herhaling',
            'recommendation.review_now' => 'Herhaal nu: :label',
            'recommendation.due_revision' => 'Dit concept staat gepland voor herhaling.',
            'recommendation.weak_area' => 'Oefen een zwak punt',
            'recommendation.continue_upload' => 'Ga verder met het laatste document',
            'recommendation.streak_rescue' => 'Reeks-reddingssessie',
            'recommendation.streak_subtitle' => 'Houd je reeks met een snelle herhaling van 2 minuten.',
            'recommendation.quick_practice' => 'Start een snelle oefening',
            'recommendation.memory_paused' => 'Personalisatie is gepauzeerd. Je kunt nog steeds leren.',
        ],
    ];

    public static function get(string $key, string $locale = 'en', array $replace = []): string
    {
        $text = self::TRANSLATIONS[$locale][$key]
            ?? self::TRANSLATIONS['en'][$key]
            ?? $key;

        foreach ($replace as $placeholder => $value) {
            $text = str_replace(':'.$placeholder, $value, $text);
        }

        return $text;
    }
}
```

**Usage in RevisionComposer:**

```php
// Before:
'prompt' => 'Which concept should you review now?',

// After:
use App\Support\Translator;

$lang = $childProfile->preferred_language ?? 'en';
'prompt' => Translator::get('revision.review_prompt', $lang),
```

### Phase 4: AI Pipeline — Concept Key Policy

Ensure concept keys remain English kebab-case regardless of document/content language.

**Files to modify:**

- `backend/app/Services/Concepts/PrismConceptExtractor.php` — add language-neutral key instruction to prompt
- `backend/app/Services/Concepts/ConceptExtractorInterface.php` — add optional `?string $language` parameter
- `backend/app/Services/Concepts/StubConceptExtractor.php` — update signature
- `backend/app/Jobs/ExtractConceptsFromDocument.php` — pass `$document->language` to extractor

**Prompt change for PrismConceptExtractor:**

```php
// Add to the user prompt:
'IMPORTANT: concept_key values MUST always be in English kebab-case (e.g., "quadratic-equations", "photosynthesis") '
. 'even if the source text is in another language. '
. 'The concept_label and concept_description should use the same language as the source text.'
. ($language ? "\nSource text language: {$language}" : '')
```

**Interface change:**

```php
// Before:
public function extract(string $text): array;

// After:
public function extract(string $text, ?string $language = null): array;
```

### Phase 5: Language Picker UI + Seeder

**Flutter — language picker on profile creation:**

Add a language dropdown to `create_profile_screen.dart` and to the child profile edit screen (if one exists). The picker shows:
- English
- Francais
- Nederlands

When a child is selected (or created), `AppState` updates the locale.

**Flutter — backend_client.dart:**

Ensure `createChild()` and `updateChild()` pass `preferred_language`.

**Backend — restrict `preferred_language` to supported languages:**

```php
// In ChildProfileController::rules()
'preferred_language' => [...$s, 'nullable', 'string', Rule::in(['en', 'fr', 'nl'])],
```

This replaces the current regex validation. If more languages are added later, expand this list.

**Backend — TestSeeder update:**

```php
// backend/database/seeders/TestSeeder.php
// Add Judith alongside or replacing Alex:
$judith = ChildProfile::create([
    'user_id' => (string) $user->_id,
    'name' => 'Judith',
    'grade_level' => '1ere secondaire',
    'birth_year' => 2014,
    'preferred_language' => 'fr',
    'notes' => 'Belgium, French-speaking',
]);
```

**Backend — ChildProfileFactory update:**

```php
// Add preferred_language to factory definition:
'preferred_language' => fake()->randomElement(['en', 'fr', 'nl']),
```

## Acceptance Criteria

### Functional Requirements

- [x] Flutter app displays all UI strings in the child's `preferred_language`
- [x] Switching child profiles switches the app locale
- [x] Before a child is selected, the app follows the device locale (fallback to English)
- [x] ARB files exist for `en`, `fr`, `nl` with all ~120+ extracted strings
- [x] ICU plural syntax is used for strings with counts (concepts, cards, questions, days)
- [x] Backend revision prompts and recommendation titles are translated server-side
- [x] `RevisionComposer` uses `Translator::get()` with child's `preferred_language`
- [x] `MemorySignalProjector` uses `Translator::get()` with child's `preferred_language`
- [x] `RevisionSessionController` returns translated session labels
- [x] Concept keys remain English kebab-case regardless of source language
- [x] `PrismConceptExtractor` prompt explicitly instructs English keys + localized labels
- [x] Language picker appears on profile creation screen (EN/FR/NL)
- [x] `preferred_language` validation restricts to `en`, `fr`, `nl`
- [x] TestSeeder creates Judith: name="Judith", birth_year=2014, grade_level="1ere secondaire", preferred_language="fr"
- [x] True/False game labels show localized text ("Vrai"/"Faux" in French)
- [x] Day-of-week abbreviations use `intl` DateFormat for localization
- [x] Processing screen fun facts are translated
- [x] iOS `Info.plist` declares `CFBundleLocalizations` for en, fr, nl

### Testing Requirements

- [x] Widget test verifying all locales load without error
- [ ] Backend test for `Translator::get()` with each locale + fallback
- [ ] Backend test confirming RevisionComposer returns French strings for `preferred_language: 'fr'`
- [x] Existing tests continue to pass (33/35 backend, 7/7 Flutter widget)

## Dependencies & Risks

**Dependencies:**
- `flutter_localizations` SDK package (bundled with Flutter, no version risk)
- `intl` package (bundled with `flutter_localizations`)
- No new backend dependencies

**Risks:**
- **Translation quality:** Initial FR/NL translations are developer-written, not professional. Should be reviewed by native speakers before production.
- **String extraction volume:** ~120+ strings across 15+ files is mechanical but time-consuming. Risk of missing strings.
- **AppState context access:** `AppState` (a `ChangeNotifier`) does not have `BuildContext`. Strings generated in `AppState` (e.g., True/False labels, day names) need a different approach — either passing locale explicitly or moving string generation to the widget layer.
- **Processing screen string matching:** `_ProcessingSteps` widget at lines 1685-1694 uses `currentStatus.contains('Processing')` to determine step progress. Localizing status messages requires changing this to use stage codes instead of display text.

## References & Research

### Internal References

- `backend/app/Models/ChildProfile.php:20` — `preferred_language` field
- `backend/app/Models/ChildProfile.php:108-118` — `setPreferredLanguageAttribute` mutator
- `backend/app/Http/Controllers/Api/ChildProfileController.php:96` — current regex validation
- `backend/app/Services/Generation/PrismLearningPackGenerator.php:77-78,100` — language prompt + `$document->language`
- `backend/app/Services/Generation/PrismGameGenerator.php:88-89` — game language prompt
- `backend/app/Services/Concepts/PrismConceptExtractor.php:35,58-76` — no language awareness
- `backend/app/Services/Revision/RevisionComposer.php:87,126-127,138-143,188-194` — hardcoded English strings
- `backend/app/Services/Memory/MemorySignalProjector.php:34-35,73,102,123-124,145-146` — hardcoded English strings
- `backend/app/Http/Controllers/Api/RevisionSessionController.php:35,207` — hardcoded "Quick Revision"
- `mobile/learny_app/lib/state/app_state.dart:287-296,1136-1206,1348` — hardcoded English (days, status, True/False)
- `mobile/learny_app/lib/screens/home/home_screen.dart` — ~25 hardcoded strings
- `mobile/learny_app/lib/screens/games/quiz_screen.dart` — ~20 hardcoded strings
- `specs/personalized_learner_profile_2_0_spec.md:37` — "Advanced multilingual localization" was out of Phase 1 scope

### External References

- [Flutter official i18n guide](https://docs.flutter.dev/ui/internationalization)
- [Flutter breaking change: synthetic-package false required on 3.32+](https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source)
- [ARB file format reference](https://localizely.com/flutter-arb/)
- [ICU MessageFormat syntax](https://www.applanga.com/docs/translation-management-dashboard/icu-syntax)

### Key Decisions Made

| Decision | Choice | Rationale |
|---|---|---|
| AI content language | Follows document language | Child uploads French doc → gets French games. English doc → English games. |
| Concept key language | Always English kebab-case | Stable mastery tracking across languages. No concept fragmentation. |
| Backend string localization | Server-side PHP translation maps | Simple, no new dependencies, keeps client thin. |
| Flutter locale source | Child's `preferred_language` | Per-child locale. Falls back to device locale before child selection. |
| Supported languages | EN, FR, NL | Belgium trilingual context. Validation restricts to these three. |
| Existing content on language change | Stays as-is | No re-generation. New content uses new language. |
