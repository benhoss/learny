import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class SafetyPrivacyScreen extends StatelessWidget {
  const SafetyPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.safetyPrivacyTitle,
      subtitle: l.safetyPrivacySubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.shield_rounded, color: LearnyColors.coral),
            title: Text(l.safetyPrivacyCoppaTitle),
            subtitle: Text(l.safetyPrivacyCoppaSubtitle),
          ),
          ListTile(
            leading: const Icon(Icons.lock_rounded, color: LearnyColors.teal),
            title: Text(l.safetyPrivacyEncryptedTitle),
            subtitle: Text(l.safetyPrivacyEncryptedSubtitle),
          ),
          ListTile(
            leading: const Icon(Icons.visibility_off_rounded, color: LearnyColors.purple),
            title: Text(l.safetyPrivacyNoAdsTitle),
            subtitle: Text(l.safetyPrivacyNoAdsSubtitle),
          ),
        ],
      ),
    );
  }
}
