import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: L10n.of(context).achievementsTitle,
      subtitle: L10n.of(context).achievementsSubtitle,
      gradient: LearnyGradients.hero,
      body: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: state.achievements
            .map(
              (achievement) => _Badge(
                label: achievement.title,
                icon: achievement.icon,
                isUnlocked: achievement.isUnlocked,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.isUnlocked,
  });

  final String label;
  final IconData icon;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : LearnyColors.slateLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: isUnlocked ? LearnyColors.coral : LearnyColors.slateMedium),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
