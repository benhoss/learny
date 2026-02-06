import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learny_app/theme/app_theme.dart';
import 'package:learny_app/widgets/games/answer_chip.dart';
import 'package:learny_app/widgets/games/feedback_banner.dart';
import 'package:learny_app/widgets/games/mastery_meter.dart';
import 'package:learny_app/widgets/games/progress_bar.dart';
import 'package:learny_app/widgets/games/result_summary_card.dart';
import 'package:learny_app/widgets/games/streak_pill.dart';
import 'package:learny_app/widgets/games/timer_badge.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: LearnyTheme.light(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 240, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('AnswerChip renders text and selection state', (tester) async {
    await tester.pumpWidget(_wrap(const AnswerChip(text: 'Option A')));
    expect(find.text('Option A'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(const AnswerChip(text: 'Option B', isSelected: true)),
    );
    expect(find.text('Option B'), findsOneWidget);
  });

  testWidgets('TimerBadge counts down', (tester) async {
    await tester.pumpWidget(_wrap(const TimerBadge(seconds: 3)));
    expect(find.text('3s'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2s'), findsOneWidget);
  });

  testWidgets('StreakPill shows count', (tester) async {
    await tester.pumpWidget(_wrap(const StreakPill(count: 7)));
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('MasteryMeter shows percentage', (tester) async {
    await tester.pumpWidget(_wrap(const MasteryMeter(percent: 0.72)));
    expect(find.text('Mastery 72%'), findsOneWidget);
  });

  testWidgets('FeedbackBanner shows correct state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const FeedbackBanner(
          message: 'Nice work!',
          isCorrect: true,
          secondsLeft: 4,
        ),
      ),
    );
    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('Nice work!'), findsOneWidget);
    expect(find.text('4s'), findsOneWidget);
  });

  testWidgets('ResultSummaryCard shows metrics', (tester) async {
    await tester.pumpWidget(
      _wrap(const ResultSummaryCard(correct: 8, total: 10, streak: 3, masteryDelta: 6)),
    );
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('8 of 10 correct'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);
    expect(find.text('+6%'), findsOneWidget);
  });

  testWidgets('ProgressBar shows label when enabled', (tester) async {
    await tester.pumpWidget(_wrap(const ProgressBar(progress: 60, showLabel: true)));
    expect(find.text('60% complete'), findsOneWidget);
  });
}
