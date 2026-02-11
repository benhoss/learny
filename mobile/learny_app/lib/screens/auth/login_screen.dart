import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.loginTitle,
      subtitle: l.loginSubtitle,
      gradient: LearnyGradients.hero,
      body: Column(
        children: [
          TextField(decoration: InputDecoration(labelText: l.authEmailLabel)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(labelText: l.authPasswordLabel),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.forgotPassword),
              child: Text(l.loginForgotPassword),
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () async {
          await state.completeOnboarding(force: true);
          if (!context.mounted) return;
          Navigator.pushNamed(context, AppRoutes.home);
        },
        child: Text(l.loginButton),
      ),
      secondaryAction: TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
        child: Text(l.loginCreateAccountPrompt),
      ),
    );
  }
}
