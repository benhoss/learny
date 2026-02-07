import 'package:flutter/material.dart';
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
      title: 'Revision Express',
      subtitle: 'Quick 5-minute boost before a test.',
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.timer_rounded, color: LearnyColors.coral),
            title: Text('Duration'),
            subtitle: Text('5 minutes'),
          ),
          ListTile(
            leading: const Icon(Icons.book_rounded, color: LearnyColors.teal),
            title: const Text('Subject focus'),
            subtitle: Text(
              pack == null ? 'Pick a pack' : '${pack.subject} • ${pack.title}',
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.psychology_alt_rounded,
              color: LearnyColors.skyPrimary,
            ),
            title: const Text('Adaptive mix'),
            subtitle: Text(
              state.reviewDueCount > 0
                  ? 'Due concepts + recent mistakes + latest uploads'
                  : 'Recent mistakes + latest uploads',
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
              const SnackBar(
                content: Text(
                  'No revision items are ready yet. Complete a game first.',
                ),
              ),
            );
            return;
          }
          Navigator.pushNamed(context, AppRoutes.revisionSession);
        },
        child: const Text('Start Express Session'),
      ),
    );
  }
}
