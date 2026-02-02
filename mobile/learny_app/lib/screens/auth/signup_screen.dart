import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Create Parent Account',
      subtitle: 'Set up a secure parent profile to manage learning.',
      gradient: LearnyGradients.hero,
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 20),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.verifyEmail),
        child: const Text('Create Account'),
      ),
      secondaryAction: TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        child: const Text('Already have an account? Log in'),
      ),
    );
  }
}
