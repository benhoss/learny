import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Parent Settings',
      subtitle: 'Manage subscription and family controls.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.pin_rounded, color: LearnyColors.coral),
            title: const Text('Set / Change PIN'),
            subtitle: const Text('Protect parent-only settings.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.parentPin,
              arguments: {'mode': 'change'},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded, color: LearnyColors.coral),
            title: const Text('Subscription'),
            subtitle: Text('Current plan: ${state.currentPlan}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: LearnyColors.teal),
            title: const Text('Parent profile'),
            subtitle: Text(state.parentProfile.email),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.accountSettings),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_rounded, color: LearnyColors.purple),
            title: const Text('Child profiles'),
            subtitle: Text('${state.children.length} profiles'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.childSelector),
          ),
        ],
      ),
    );
  }
}
