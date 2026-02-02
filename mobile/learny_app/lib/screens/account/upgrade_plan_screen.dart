import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class UpgradePlanScreen extends StatelessWidget {
  const UpgradePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Upgrade Plan',
      subtitle: 'Unlock unlimited packs and parent insights.',
      gradient: LearnyGradients.hero,
      body: Column(
        children: state.planOptions
            .map(
              (plan) => Card(
                color: plan.isHighlighted ? LearnyColors.slateDark : Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: plan.isHighlighted ? LearnyColors.coral : LearnyColors.peach,
                    child: Icon(
                      plan.isHighlighted ? Icons.star_rounded : Icons.family_restroom_rounded,
                      color: plan.isHighlighted ? Colors.white : LearnyColors.coral,
                    ),
                  ),
                  title: Text(
                    plan.name,
                    style: TextStyle(
                      color: plan.isHighlighted ? Colors.white : LearnyColors.slateDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${plan.priceLabel} • ${plan.description}',
                    style: TextStyle(
                      color: plan.isHighlighted ? Colors.white70 : LearnyColors.slateMedium,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: const Text('Continue to Checkout'),
      ),
    );
  }
}
