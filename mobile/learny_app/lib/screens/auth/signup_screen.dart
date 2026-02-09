import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.signupTitle,
      subtitle: l.signupSubtitle,
      gradient: LearnyGradients.hero,
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: l.signupFullNameLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(labelText: l.authEmailLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(labelText: l.authPasswordLabel),
          ),
          const SizedBox(height: 20),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.verifyEmail),
        child: Text(l.signupCreateAccount),
      ),
      secondaryAction: TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        child: Text(l.signupLoginPrompt),
      ),
    );
  }
}
