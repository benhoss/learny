import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.subscriptionTitle,
      subtitle: l.subscriptionSubtitle,
      gradient: LearnyGradients.hero,
      body: ListTile(
        leading: const Icon(Icons.workspace_premium_rounded, color: LearnyColors.coral),
        title: Text(l.subscriptionCurrentPlan(state.currentPlan)),
        subtitle: Text(l.subscriptionPlanIncluded),
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.upgradePlan),
        child: Text(l.subscriptionUpgradePlan),
      ),
    );
  }
}
