import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.parentSettingsTitle,
      subtitle: l.parentSettingsSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.pin_rounded, color: LearnyColors.coral),
            title: Text(l.parentSettingsSetChangePin),
            subtitle: Text(l.parentSettingsProtectSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.parentPin,
              arguments: {'mode': 'change'},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded, color: LearnyColors.coral),
            title: Text(l.parentSettingsSubscription),
            subtitle: Text(l.subscriptionCurrentPlan(state.currentPlan)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: LearnyColors.teal),
            title: Text(l.parentSettingsParentProfile),
            subtitle: Text(state.parentProfile.email),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.accountSettings),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_rounded, color: LearnyColors.purple),
            title: Text(l.parentSettingsChildProfiles),
            subtitle: Text(l.parentSettingsProfilesCount(state.children.length)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.childSelector),
          ),
        ],
      ),
    );
  }
}
