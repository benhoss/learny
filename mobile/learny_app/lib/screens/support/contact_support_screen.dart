import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Contact Support',
      subtitle: 'We usually respond within 24 hours.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'From: ${state.parentProfile.email}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.supportTopics
                .map((topic) => Chip(label: Text(topic)))
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Topic'),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Message'),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: const Text('Send Message'),
      ),
    );
  }
}
