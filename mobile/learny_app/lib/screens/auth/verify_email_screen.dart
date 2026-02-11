import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.verifyEmailTitle,
      subtitle: l.verifyEmailSubtitle,
      gradient: LearnyGradients.trust,
      body: TextField(
        decoration: InputDecoration(labelText: l.verifyEmailCodeLabel),
      ),
      primaryAction: ElevatedButton(
        onPressed: () async {
          await state.completeOnboarding(force: true);
          if (!context.mounted) return;
          Navigator.pushNamed(context, AppRoutes.home);
        },
        child: Text(l.verifyEmailContinueToApp),
      ),
      secondaryAction: TextButton(
        onPressed: () {},
        child: Text(l.verifyEmailResendCode),
      ),
    );
  }
}
