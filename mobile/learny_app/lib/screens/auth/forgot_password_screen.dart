import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Reset Password',
      subtitle: 'We\'ll send a reset link to your email.',
      gradient: LearnyGradients.trust,
      body: TextField(
        decoration: const InputDecoration(labelText: 'Email address'),
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Send Link'),
      ),
    );
  }
}
