import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learny_app/screens/home/home_screen.dart';
import 'package:learny_app/state/app_state.dart';
import 'package:learny_app/state/app_state_scope.dart';
import 'package:learny_app/theme/app_theme.dart';
import 'package:learny_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('home recommendation shows why dialog when enabled', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState(initializeBackendSession: false);
    state.recommendationWhyEnabled = true;
    state.homeRecommendations = [
      {
        'id': 'rec-1',
        'title': 'Review now: Fractions',
        'subtitle': 'This concept is due.',
        'action': 'start_revision',
        'explainability': {
          'source': 'mastery_profiles.next_review_at',
          'due_at': DateTime.now().toUtc().toIso8601String(),
        },
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: LearnyTheme.light(),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: AppStateScope(
          notifier: state,
          child: const Scaffold(body: HomeScreen()),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Why this?'));
    await tester.pumpAndSettle();

    expect(find.text('Why this recommendation?'), findsOneWidget);
    expect(find.textContaining('source:'), findsWidgets);
  });
}
