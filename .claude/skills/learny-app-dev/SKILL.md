---
name: learny-app-dev
description: "This skill should be used when implementing features, fixing bugs, or making changes in the Learny Flutter mobile app. This includes creating or modifying screens, widgets, models, services, state management, localization, routing, animations, and tests. Triggers on any Flutter/Dart work, UI changes, game screen modifications, state management updates, localization additions, or navigation changes."
---

# Learny Flutter App Development

## Stack

- Flutter SDK ^3.10.1, Dart 3
- State: `ChangeNotifier` + `InheritedNotifier` (no Provider/Riverpod)
- HTTP: `http` ^1.2.2 with JWT bearer auth
- Icons: `lucide_icons` ^0.257.0
- Fonts: `google_fonts` ^6.2.1 (Nunito body, Poppins headings)
- L10n: Flutter's built-in `flutter_localizations` + `intl` + ARB files
- Camera/files: `image_picker` ^1.1.2, `file_picker` ^8.1.2
- Tests: `flutter_test`, `golden_toolkit` ^0.15.0

## Architecture Reference

For full model schemas, screen catalog, widget inventory, route map, backend client API, and design tokens, read `references/architecture.md`.

## Critical Rules

### State Access

Always use `AppStateScope.of(context)` — never import `AppState` directly in screens:

```dart
final state = AppStateScope.of(context);
```

`AppStateScope` is an `InheritedNotifier<AppState>` — widgets rebuild automatically when `notifyListeners()` is called.

### Routing

Named routes only. All constants live in `AppRoutes` (`lib/routes/app_routes.dart`):

```dart
Navigator.pushNamed(context, AppRoutes.quiz);
Navigator.pushReplacementNamed(context, AppRoutes.results);
Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
```

No route parameters — pass data through `AppState` fields (e.g., `selectedPackId`, `currentGameType`).

New routes must be registered in both `AppRoutes` and the `routes:` map in `lib/app/app.dart`.

### Localization (L10n)

All user-facing strings go in ARB files, never hardcoded:

```dart
final l10n = L10n.of(context);
Text(l10n.homeGreeting)                           // simple string
Text(l10n.gameCardProgress(current, total))       // interpolation
Text(l10n.homeReviewCount(count))                 // plural
```

ARB files in `lib/l10n/`: `app_en.arb` (template), `app_fr.arb`, `app_nl.arb`. After editing, run:

```bash
cd mobile/learny_app && flutter gen-l10n
```

Key naming convention: `{feature}{Element}` in camelCase. Plurals use ICU syntax:

```json
{
  "homeReviewCount": "{count, plural, =1{1 concept to review} other{{count} concepts to review}}",
  "@homeReviewCount": { "description": "Review due count", "placeholders": { "count": { "type": "int" } } }
}
```

**AppState has no BuildContext** — strings generated in AppState (day labels, True/False) must use locale passed explicitly or be generated in the widget layer.

### MongoDB ID Extraction

Backend returns `_id` as either `"abc123"` or `{"$oid": "abc123"}`. Always handle both:

```dart
final rawId = json['_id'] ?? json['id'];
String? id;
if (rawId is Map) {
  id = (rawId[r'$oid'] ?? rawId['oid'])?.toString();
} else {
  id = rawId?.toString();
}
```

Use `AppState._extractId()` for this — it's the canonical helper.

### Screen Pattern

```dart
import 'package:flutter/material.dart';
import '../../state/app_state_scope.dart';
import '../../routes/app_routes.dart';
import '../../l10n/generated/app_localizations.dart';

class NewFeatureScreen extends StatefulWidget {
  const NewFeatureScreen({super.key});

  @override
  State<NewFeatureScreen> createState() => _NewFeatureScreenState();
}

class _NewFeatureScreenState extends State<NewFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l10n = L10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(l10n.featureTitle),
            // ...
          ],
        ),
      ),
    );
  }
}
```

### Async Navigation Safety

Always check `context.mounted` before navigating after an async call:

```dart
await state.someAsyncMethod();
if (!context.mounted) return;
Navigator.pushNamed(context, AppRoutes.results);
```

### Game Screen Pattern

Game screens follow a consistent structure:

1. Wrap in `GameScaffold` for gradient background + decorative circles
2. Use `GameHeader` for title, progress, timer, streak
3. Load game data in `didChangeDependencies()` via AppState
4. Stagger answer options with `FadeInSlide(delay: Duration(milliseconds: 100 + i * 50))`
5. Submit answers via `state.answerCurrentQuestion*()` methods
6. Navigate to next game or results on completion

### Animation Pattern

Use `FadeInSlide` for entry animations (most common):

```dart
FadeInSlide(
  delay: Duration(milliseconds: 100 + (index * 50)),
  duration: const Duration(milliseconds: 400),
  offset: 20.0,
  child: widget,
)
```

For animation controllers, always use `SingleTickerProviderStateMixin`, check `mounted` in callbacks, and cancel timers in `dispose()`:

```dart
@override
void dispose() {
  _startTimer?.cancel();
  _controller.dispose();
  super.dispose();
}
```

### Design System

Colors via `LearnyColors.*`, tokens via `context.tokens.*`:

```dart
LearnyColors.skyPrimary     // #7DD3E8 — primary blue
LearnyColors.mintPrimary    // #8FE5C2 — success/mint
LearnyColors.neutralDark    // #2D3748 — text
LearnyColors.cream          // #FFF8F0 — background
LearnyColors.coral          // #FF9A8B — error/warning

context.tokens.spaceMd      // 16.0
context.tokens.radiusLg     // 16.0
```

Typography: Poppins for headings (display/headline/title), Nunito for body.

### Widget Conventions

- Reusable game widgets: `lib/widgets/games/` (GameScaffold, GameHeader, AnswerChip, FeedbackBanner, etc.)
- Animation widgets: `lib/widgets/animations/` (FadeInSlide, FlipCard, ScreenTransition)
- PascalCase class names, snake_case filenames
- `const` constructors where possible
- Haptic feedback via `HapticService.success()`, `.error()`, `.flip()`

## State Management

`AppState` (~2650 lines) is the single source of truth. Key patterns:

```dart
// Mutate + notify
someField = newValue;
notifyListeners();

// Async operation pattern
isLoading = true;
notifyListeners();
try {
  await backend.someCall();
  // update fields
} catch (e) {
  errorMessage = e.toString();
} finally {
  isLoading = false;
  notifyListeners();
}
```

Game payloads organized by type:

```dart
gamePayloads: Map<String, Map<String, dynamic>>  // type → payload
gameIds: Map<String, String>                      // type → backend game ID
```

When switching children, all session state must be cleared (quiz, games, packs, revision, recommendations).

## Backend Client

`BackendClient` (`lib/services/backend_client.dart`, ~814 lines) — thin HTTP wrapper:

- Base URL from `BackendConfig.baseUrl`
- JWT token set after login/register
- All methods return `Map<String, dynamic>` or `List<dynamic>`
- Throws `BackendException` on non-success status
- Game results retry: up to 2 attempts with 2s delay

## Commands

```bash
cd mobile/learny_app

flutter pub get                                    # Install deps
flutter run                                        # Run app
flutter test                                       # All tests
flutter test test/games_widgets_test.dart           # Widget tests (7/7 pass)
flutter analyze                                    # Lint (must run from mobile/learny_app/)
flutter gen-l10n                                   # Regenerate L10n after ARB edits
```

## New Feature Checklist

1. **Model** in `lib/models/` — immutable with `fromJson()`, `copyWith()` if needed. Handle `_id`/`{$oid}`.
2. **Screen** in `lib/screens/{feature}/` — use `AppStateScope.of(context)`, `L10n.of(context)`, named routes.
3. **Route** in `lib/routes/app_routes.dart` + `lib/app/app.dart` routes map.
4. **State** in `lib/state/app_state.dart` — add fields, methods, clear on child switch if session-scoped.
5. **Backend calls** in `lib/services/backend_client.dart` — match existing JSON/auth pattern.
6. **L10n** — add keys to all 3 ARB files (en/fr/nl), run `flutter gen-l10n`.
7. **Widgets** — extract reusable pieces to `lib/widgets/`.
8. **Test** — widget test or golden test in `test/`.
9. **Analyze** — `cd mobile/learny_app && flutter analyze`

## Gotchas

- `flutter analyze` must run from `mobile/learny_app/`, not repo root
- `widget_test.dart` has pre-existing FadeInSlide animation timer failures — unrelated to new work
- `games_widgets_test.dart` (7 tests) always passes — use as regression baseline
- `BackendConfig.disableOnboarding` bypasses welcome/auth screens for dev
- Demo credentials in `BackendConfig` auto-login on app start — don't rely on onboarding flow for testing
- Game payload `topic` field must match `concept_key` from learning pack
- Row widgets with dynamic text must use `Expanded` to prevent overflow (especially in translated strings that are longer than English)
- `synthetic-package: false` in `l10n.yaml` — import from `lib/l10n/generated/`, not `package:flutter_gen`
- Processing screen status matching uses stage codes, not display text — don't localize status comparison strings
