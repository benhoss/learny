import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ParentPinScreen extends StatelessWidget {
  const ParentPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    final mode = args is Map<String, dynamic> ? args['mode'] as String? : null;
    final isChangePin = mode == 'change';
    return PlaceholderScreen(
      title: isChangePin ? l.parentPinChangeTitle : l.parentSettingsTitle,
      subtitle: isChangePin
          ? l.parentPinChangeSubtitle
          : l.parentPinEnterSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.parentPinCodeLabel),
            obscureText: true,
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.parentSettings),
        child: Text(
          isChangePin ? l.parentPinSaveButton : l.parentPinUnlockButton,
        ),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l.commonCancel),
      ),
    );
  }
}
