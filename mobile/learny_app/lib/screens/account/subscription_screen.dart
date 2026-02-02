import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Subscription',
      subtitle: 'Learny is free to use. Parents can upgrade anytime.',
      gradient: LearnyGradients.hero,
      body: ListTile(
        leading: const Icon(Icons.workspace_premium_rounded, color: LearnyColors.coral),
        title: Text('Current plan: ${state.currentPlan}'),
        subtitle: const Text('Full access included with the free plan.'),
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.upgradePlan),
        child: const Text('Upgrade Plan'),
      ),
    );
  }
}
