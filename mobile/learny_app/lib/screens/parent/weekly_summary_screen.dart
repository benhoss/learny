import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    final summary = state.weeklySummary;
    return PlaceholderScreen(
      title: l.weeklySummaryTitle,
      subtitle: l.weeklySummarySubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.timer_rounded, color: LearnyColors.coral),
            title: Text(l.weeklySummaryTimeSpent),
            subtitle: Text(
              l.weeklySummaryTimeSpentValue(
                summary.minutesSpent ~/ 60,
                summary.minutesSpent % 60,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_rounded, color: LearnyColors.teal),
            title: Text(l.weeklySummaryAchievements),
            subtitle: Text(l.weeklySummaryNewBadges(summary.newBadges)),
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories_rounded, color: LearnyColors.purple),
            title: Text(l.weeklySummarySessionsCompleted),
            subtitle: Text(l.weeklySummarySessionsValue(summary.sessionsCompleted)),
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: LearnyColors.coral),
            title: Text(l.weeklySummaryTopSubject),
            subtitle: Text(summary.topSubject),
          ),
        ],
      ),
    );
  }
}
