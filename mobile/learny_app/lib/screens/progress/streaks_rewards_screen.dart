import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class StreaksRewardsScreen extends StatelessWidget {
  const StreaksRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.streaksRewardsTitle,
      subtitle: l.streaksRewardsSubtitle,
      gradient: LearnyGradients.hero,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.local_fire_department_rounded, color: LearnyColors.coral),
            title: Text(l.streaksRewardsCurrentStreak),
            subtitle: Text(l.streaksRewardsDays(state.streakDays)),
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: LearnyColors.teal),
            title: Text(l.streaksRewardsUnlocked),
            subtitle: Text(
              l.streaksRewardsBadges(
                state.achievements.where((a) => a.isUnlocked).length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
