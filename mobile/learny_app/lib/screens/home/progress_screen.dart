import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final masteryValues = state.mastery.values.toList();
    final masteryAverage = masteryValues.isEmpty
        ? 0.0
        : masteryValues.reduce((a, b) => a + b) / masteryValues.length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Progress',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Mastery trends and streaks.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: LearnyColors.slateMedium),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Progress'),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: masteryAverage),
              const SizedBox(height: 8),
              Text('${(masteryAverage * 100).round()}% mastery across this week\'s packs'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ActionCard(
              label: 'Mastery Details',
              route: AppRoutes.masteryDetail,
              icon: Icons.track_changes_rounded,
            ),
            _ActionCard(
              label: 'Streaks & Rewards',
              route: AppRoutes.streaksRewards,
              icon: Icons.local_fire_department_rounded,
            ),
            _ActionCard(
              label: 'Achievements',
              route: AppRoutes.achievements,
              icon: Icons.emoji_events_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.progressOverview),
          child: const Text('Open Progress Overview'),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.pushNamed(context, route),
      child: Ink(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: LearnyColors.coral),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
