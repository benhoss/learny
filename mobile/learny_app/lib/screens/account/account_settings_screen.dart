import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.accountSettingsTitle,
      subtitle: l.accountSettingsSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          TextFormField(
            initialValue: state.parentProfile.name,
            decoration: InputDecoration(labelText: l.accountSettingsNameLabel),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.parentProfile.email,
            decoration: InputDecoration(labelText: l.accountSettingsEmailLabel),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.profile.gradeLabel,
            decoration: InputDecoration(
              labelText: l.accountSettingsGradeRangeLabel,
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: Text(l.accountSettingsSaveChanges),
      ),
    );
  }
}
