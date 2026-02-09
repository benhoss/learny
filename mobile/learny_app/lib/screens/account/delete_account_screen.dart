import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.deleteAccountTitle,
      subtitle: l.deleteAccountSubtitle,
      gradient: LearnyGradients.trust,
      body: Text(
        l.deleteAccountBody(state.parentProfile.name),
      ),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: Text(l.deleteAccountConfirmDelete),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l.commonCancel),
      ),
    );
  }
}
