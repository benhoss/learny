import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.forgotPasswordTitle,
      subtitle: l.forgotPasswordSubtitle,
      gradient: LearnyGradients.trust,
      body: TextField(
        decoration: InputDecoration(labelText: l.forgotPasswordEmailAddressLabel),
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l.forgotPasswordSendLink),
      ),
    );
  }
}
