import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.emptyStateTitle,
      subtitle: l.emptyStateSubtitle,
      gradient: LearnyGradients.hero,
      body: const Icon(Icons.inbox_rounded, size: 80, color: LearnyColors.slateLight),
    );
  }
}
