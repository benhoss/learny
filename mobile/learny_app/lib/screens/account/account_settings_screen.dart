import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Account Settings',
      subtitle: 'Manage parent profile and preferences.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          TextFormField(
            initialValue: state.parentProfile.name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.parentProfile.email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.profile.gradeLabel,
            decoration: const InputDecoration(labelText: 'Preferred grade range'),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: const Text('Save Changes'),
      ),
    );
  }
}
