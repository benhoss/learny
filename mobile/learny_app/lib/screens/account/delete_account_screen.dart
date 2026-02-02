import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Delete Account',
      subtitle: 'This action is permanent.',
      gradient: LearnyGradients.trust,
      body: Text(
        'Deleting ${state.parentProfile.name}\'s account will remove all child profiles and documents. This cannot be undone.',
      ),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: const Text('Confirm Delete'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    );
  }
}
