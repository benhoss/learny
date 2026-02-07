import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ParentPinScreen extends StatelessWidget {
  const ParentPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final mode = args is Map<String, dynamic> ? args['mode'] as String? : null;
    final isChangePin = mode == 'change';
    return PlaceholderScreen(
      title: isChangePin ? 'Change PIN' : 'Parent Settings',
      subtitle: isChangePin
          ? 'Set a new PIN for parent-only access.'
          : 'Enter your PIN to continue.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: const [
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '4-digit PIN'),
            obscureText: true,
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.parentSettings),
        child: Text(isChangePin ? 'Save PIN' : 'Unlock Parent Settings'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    );
  }
}
