import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class MasteryDetailScreen extends StatelessWidget {
  const MasteryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final masteryEntries = state.mastery.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return PlaceholderScreen(
      title: 'Mastery Details',
      subtitle: masteryEntries.isEmpty
          ? 'Upload and complete games to build concept mastery.'
          : 'Concept-level breakdown from your uploaded study content.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: masteryEntries.isEmpty
            ? const [
                ListTile(
                  leading: Icon(Icons.hourglass_empty_rounded),
                  title: Text('No mastery data yet'),
                  subtitle: Text(
                    'Run at least one generated game to populate this view.',
                  ),
                ),
              ]
            : masteryEntries.map((entry) {
                final pct = (entry.value * 100).round();
                final icon = pct >= 80
                    ? Icons.check_circle_rounded
                    : pct >= 50
                    ? Icons.timelapse_rounded
                    : Icons.error_outline_rounded;
                final color = pct >= 80
                    ? LearnyColors.teal
                    : pct >= 50
                    ? LearnyColors.coral
                    : LearnyColors.purple;
                final label = pct >= 80
                    ? 'Mastered'
                    : pct >= 50
                    ? 'Practicing'
                    : 'Needs review';
                return ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(entry.key),
                  subtitle: Text('$label • $pct%'),
                );
              }).toList(),
      ),
    );
  }
}
