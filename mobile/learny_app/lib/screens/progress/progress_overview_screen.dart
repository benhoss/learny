import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ProgressOverviewScreen extends StatelessWidget {
  const ProgressOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final mastery = state.mastery.entries.toList();
    return PlaceholderScreen(
      title: 'Progress Overview',
      subtitle: 'Mastery by topic and time spent.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: mastery
            .map(
              (entry) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: LearnyColors.sky,
                  child: Text(entry.key.characters.first),
                ),
                title: Text(entry.key),
                subtitle: Text('Mastery ${(entry.value * 100).round()}%'),
              ),
            )
            .toList(),
      ),
    );
  }
}
