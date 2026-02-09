import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PlaceholderScreen(
      title: l.offlineTitle,
      subtitle: l.offlineSubtitle,
      gradient: LearnyGradients.trust,
      body: const Icon(Icons.wifi_off_rounded, size: 80, color: LearnyColors.slateLight),
      primaryAction: ElevatedButton(
        onPressed: () {},
        child: Text(l.offlineRetry),
      ),
    );
  }
}
