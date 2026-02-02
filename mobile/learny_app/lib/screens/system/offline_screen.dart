import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'You\'re Offline',
      subtitle: 'Check your connection to sync progress.',
      gradient: LearnyGradients.trust,
      body: const Icon(Icons.wifi_off_rounded, size: 80, color: LearnyColors.slateLight),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: const Text('Retry'),
      ),
    );
  }
}
