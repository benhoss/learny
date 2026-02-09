import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class LearningTimeScreen extends StatelessWidget {
  const LearningTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.learningTimeTitle,
      subtitle: l.learningTimeSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: state.learningTimes
            .map(
              (entry) => ListTile(
                leading: const Icon(Icons.calendar_today_rounded, color: LearnyColors.teal),
                title: Text(entry.dayLabel),
                trailing: Text(l.learningTimeMinutes(entry.minutes)),
              ),
            )
            .toList(),
      ),
    );
  }
}
