import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class MasteryDetailScreen extends StatelessWidget {
  const MasteryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    final masteryEntries = state.mastery.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return PlaceholderScreen(
      title: l.masteryDetailsTitle,
      subtitle: masteryEntries.isEmpty
          ? l.masteryDetailsEmptySubtitle
          : l.masteryDetailsSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: masteryEntries.isEmpty
            ? [
                ListTile(
                  leading: const Icon(Icons.hourglass_empty_rounded),
                  title: Text(l.masteryDetailsNoDataTitle),
                  subtitle: Text(l.masteryDetailsNoDataSubtitle),
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
                    ? l.masteryStatusMastered
                    : pct >= 50
                    ? l.masteryStatusPracticing
                    : l.masteryStatusNeedsReview;
                return ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(entry.key),
                  subtitle: Text(l.masteryStatusWithPercent(label, pct)),
                );
              }).toList(),
      ),
    );
  }
}
