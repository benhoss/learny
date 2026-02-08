import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:learny_app/theme/app_theme.dart';
import 'package:learny_app/theme/app_tokens.dart';
import 'package:learny_app/widgets/games/answer_chip.dart';
import 'package:learny_app/widgets/games/feedback_banner.dart';
import 'package:learny_app/widgets/games/mastery_meter.dart';
import 'package:learny_app/widgets/games/progress_bar.dart';
import 'package:learny_app/widgets/games/result_summary_card.dart';
import 'package:learny_app/widgets/games/streak_pill.dart';
import 'package:learny_app/widgets/games/timer_badge.dart';

ThemeData _testTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: LearnyColors.skyPrimary,
      secondary: LearnyColors.mintPrimary,
      surface: Colors.white,
      background: LearnyColors.cream,
      onPrimary: Colors.white,
      onSecondary: LearnyColors.neutralDark,
      onSurface: LearnyColors.neutralDark,
      onBackground: LearnyColors.neutralDark,
    ),
    scaffoldBackgroundColor: LearnyColors.cream,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: LearnyColors.neutralDark,
      displayColor: LearnyColors.neutralDark,
    ),
    extensions: const [LearnyTokens.light],
  );
}

Widget _wrap(Widget child, {double width = 260}) {
  return Theme(
    data: _testTheme(),
    child: Material(
      child: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

void main() {
  testGoldens('Game widgets snapshots', (tester) async {
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1.1)
      ..addScenario(
        'AnswerChip default',
        _wrap(const AnswerChip(text: 'Option A')),
      )
      ..addScenario(
        'AnswerChip selected',
        _wrap(const AnswerChip(text: 'Option B', isSelected: true)),
      )
      ..addScenario(
        'AnswerChip correct',
        _wrap(const AnswerChip(text: 'Correct', isCorrect: true)),
      )
      ..addScenario(
        'AnswerChip incorrect',
        _wrap(const AnswerChip(text: 'Incorrect', isCorrect: false)),
      )
      ..addScenario(
        'Timer/Streak/Mastery',
        _wrap(
          Wrap(
            alignment: WrapAlignment.center,
            children: const [
              TimerBadge(seconds: 12),
              SizedBox(width: 8),
              StreakPill(count: 5),
              SizedBox(width: 8),
              MasteryMeter(percent: 0.72),
            ],
          ),
          width: 360,
        ),
      )
      ..addScenario(
        'ProgressBar label',
        _wrap(const ProgressBar(progress: 60, showLabel: true)),
      )
      ..addScenario(
        'FeedbackBanner correct',
        _wrap(
          const FeedbackBanner(
            message: 'Nice work!',
            isCorrect: true,
            secondsLeft: 4,
          ),
        ),
      )
      ..addScenario(
        'ResultSummaryCard',
        _wrap(
          const ResultSummaryCard(
            correct: 8,
            total: 10,
            streak: 3,
            masteryDelta: 6,
          ),
        ),
      );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(700, 900),
    );
    await screenMatchesGolden(tester, 'game_widgets');
  });
}
