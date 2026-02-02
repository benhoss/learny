import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Welcome Back',
      subtitle: 'Log in to continue your child\'s learning journey.',
      gradient: LearnyGradients.hero,
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
              child: const Text('Forgot password?'),
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          state.completeOnboarding();
          Navigator.pushNamed(context, AppRoutes.home);
        },
        child: const Text('Log In'),
      ),
      secondaryAction: TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
        child: const Text('New here? Create an account'),
      ),
    );
  }
}
