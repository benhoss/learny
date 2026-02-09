import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.contactSupportTitle,
      subtitle: l.contactSupportSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l.contactSupportFrom(state.parentProfile.email),
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
            decoration: InputDecoration(labelText: l.contactSupportTopicLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: l.contactSupportMessageLabel),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: Text(l.contactSupportSendMessage),
      ),
    );
  }
}
