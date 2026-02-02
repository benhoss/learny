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
    final pack = state.selectedPack ?? (state.packs.isNotEmpty ? state.packs.first : null);
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
            subtitle: Text(pack == null ? 'Pick a pack' : '${pack.subject} • ${pack.title}'),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          state.startRevision(packId: pack?.id);
          Navigator.pushNamed(context, AppRoutes.revisionSession);
        },
        child: const Text('Start Express Session'),
      ),
    );
  }
}
