import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final summary = state.weeklySummary;
    return PlaceholderScreen(
      title: 'Weekly Summary',
      subtitle: 'Highlights from the past 7 days.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.timer_rounded, color: LearnyColors.coral),
            title: const Text('Time spent'),
            subtitle: Text('${summary.minutesSpent ~/ 60}h ${summary.minutesSpent % 60}m'),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_rounded, color: LearnyColors.teal),
            title: const Text('Achievements'),
            subtitle: Text('${summary.newBadges} new badges'),
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories_rounded, color: LearnyColors.purple),
            title: const Text('Sessions completed'),
            subtitle: Text('${summary.sessionsCompleted} sessions'),
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: LearnyColors.coral),
            title: const Text('Top subject'),
            subtitle: Text(summary.topSubject),
          ),
        ],
      ),
    );
  }
}
