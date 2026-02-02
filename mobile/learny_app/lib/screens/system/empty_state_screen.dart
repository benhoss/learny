import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Nothing Here Yet',
      subtitle: 'Upload a worksheet to get started.',
      gradient: LearnyGradients.hero,
      body: const Icon(Icons.inbox_rounded, size: 80, color: LearnyColors.slateLight),
    );
  }
}
