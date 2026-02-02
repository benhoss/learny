import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class StreaksRewardsScreen extends StatelessWidget {
  const StreaksRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Streaks & Rewards',
      subtitle: 'Keep the momentum going!',
      gradient: LearnyGradients.hero,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.local_fire_department_rounded, color: LearnyColors.coral),
            title: const Text('Current streak'),
            subtitle: Text('${state.streakDays} days'),
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: LearnyColors.teal),
            title: const Text('Rewards unlocked'),
            subtitle: Text('${state.achievements.where((a) => a.isUnlocked).length} badges'),
          ),
        ],
      ),
    );
  }
}
