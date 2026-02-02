import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final activeChild = state.profile;
    return PlaceholderScreen(
      title: 'Parent Dashboard',
      subtitle: 'Track progress and guide next steps.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_rounded, color: LearnyColors.coral),
            title: const Text('Active child'),
            subtitle: Text('${activeChild.name} • ${activeChild.gradeLabel}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: LearnyColors.slateDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Parent only',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Action(label: 'Child Selector', route: AppRoutes.childSelector),
              _Action(label: 'Weekly Summary', route: AppRoutes.weeklySummary),
              _Action(label: 'Weak Areas', route: AppRoutes.weakAreas),
              _Action(label: 'Learning Time', route: AppRoutes.learningTime),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(label),
    );
  }
}
