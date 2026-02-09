import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ErrorStateScreen extends StatelessWidget {
  const ErrorStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.errorStateTitle,
      subtitle: l.errorStateSubtitle,
      gradient: LearnyGradients.trust,
      body: const Icon(Icons.error_outline_rounded, size: 80, color: LearnyColors.coral),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: Text(l.errorStateTryAgain),
      ),
    );
  }
}
