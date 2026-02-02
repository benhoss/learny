import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class PackSessionScreen extends StatelessWidget {
  const PackSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final pack = state.selectedPack ?? (state.packs.isNotEmpty ? state.packs.first : null);
    return PlaceholderScreen(
      title: pack == null ? 'Session Roadmap' : '${pack.title} Session',
      subtitle: pack == null ? '15-minute guided flow.' : '${pack.minutes} minute guided flow.',
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ListTile(
            leading: Icon(Icons.looks_one_rounded, color: LearnyColors.coral),
            title: Text('Flashcards'),
            subtitle: Text('10 cards'),
          ),
          ListTile(
            leading: Icon(Icons.looks_two_rounded, color: LearnyColors.teal),
            title: Text('Quiz'),
            subtitle: Text('5 questions'),
          ),
          ListTile(
            leading: Icon(Icons.looks_3_rounded, color: LearnyColors.purple),
            title: Text('Matching'),
            subtitle: Text('3 rounds'),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          state.startPackSession(packId: pack?.id);
          Navigator.pushNamed(context, AppRoutes.flashcards);
        },
        child: const Text('Start Now'),
      ),
    );
  }
}
