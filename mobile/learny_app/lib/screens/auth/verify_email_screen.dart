import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Verify Your Email',
      subtitle: 'We\'ve sent a 6-digit code to parent@example.com.',
      gradient: LearnyGradients.trust,
      body: TextField(
        decoration: const InputDecoration(labelText: 'Verification code'),
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          state.completeOnboarding();
          Navigator.pushNamed(context, AppRoutes.home);
        },
        child: const Text('Continue to App'),
      ),
      secondaryAction: TextButton(
        onPressed: () {},
        child: const Text('Resend code'),
      ),
    );
  }
}
