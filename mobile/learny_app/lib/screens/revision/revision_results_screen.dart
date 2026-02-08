import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class RevisionResultsScreen extends StatelessWidget {
  const RevisionResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final session = state.revisionSession;
    final total = session?.prompts.length ?? 0;
    final correct = session?.correctCount ?? 0;
    return PlaceholderScreen(
      title: L10n.of(context).revisionResultsTitle,
      subtitle: L10n.of(context).revisionResultsSubtitle(correct),
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          const Icon(Icons.flash_on_rounded, size: 80, color: LearnyColors.teal),
          const SizedBox(height: 12),
          Text(L10n.of(context).revisionResultsAccuracy(correct, total)),
          const SizedBox(height: 6),
          Text(L10n.of(context).revisionResultsTotalXp(state.totalXp)),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          state.resetRevision();
          Navigator.pushNamed(context, AppRoutes.home);
        },
        child: Text(L10n.of(context).revisionResultsBackHome),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () {
          state.resetRevision();
          Navigator.pushNamed(context, AppRoutes.progressOverview);
        },
        child: Text(L10n.of(context).revisionResultsSeeProgress),
      ),
    );
  }
}
