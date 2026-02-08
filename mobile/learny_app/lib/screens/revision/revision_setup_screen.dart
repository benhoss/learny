import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class RevisionSetupScreen extends StatelessWidget {
  const RevisionSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final pack =
        state.selectedPack ??
        (state.packs.isNotEmpty ? state.packs.first : null);
    return PlaceholderScreen(
      title: L10n.of(context).revisionSetupTitle,
      subtitle: L10n.of(context).revisionSetupSubtitle,
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.timer_rounded, color: LearnyColors.coral),
            title: Text(L10n.of(context).revisionSetupDuration),
            subtitle: Text(L10n.of(context).revisionSetupDurationValue),
          ),
          ListTile(
            leading: const Icon(Icons.book_rounded, color: LearnyColors.teal),
            title: Text(L10n.of(context).revisionSetupSubjectFocus),
            subtitle: Text(
              pack == null ? L10n.of(context).revisionSetupPickPack : '${pack.subject} • ${pack.title}',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.psychology_alt_rounded,
              color: LearnyColors.skyPrimary,
            ),
            title: Text(L10n.of(context).revisionSetupAdaptiveMix),
            subtitle: Text(
              state.reviewDueCount > 0
                  ? L10n.of(context).revisionSetupAdaptiveFull
                  : L10n.of(context).revisionSetupAdaptivePartial,
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () async {
          final started = await state.startRevision(packId: pack?.id);
          if (!context.mounted) {
            return;
          }
          if (!started) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  L10n.of(context).revisionSetupNoItems,
                ),
              ),
            );
            return;
          }
          Navigator.pushNamed(context, AppRoutes.revisionSession);
        },
        child: Text(L10n.of(context).revisionSetupStartButton),
      ),
    );
  }
}
