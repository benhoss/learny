import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final pack = state.selectedPack ?? (state.packs.isNotEmpty ? state.packs.first : null);
    return PlaceholderScreen(
      title: pack?.title ?? 'Learning Pack',
      subtitle: pack == null
          ? 'No pack selected yet.'
          : '${pack.itemCount} cards • 3 games • ${pack.minutes} minutes',
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ListTile(
            leading: Icon(Icons.flash_on_rounded, color: LearnyColors.coral),
            title: Text('Warm-up flashcards'),
            subtitle: Text('10 cards'),
          ),
          ListTile(
            leading: Icon(Icons.quiz_rounded, color: LearnyColors.teal),
            title: Text('Quick quiz'),
            subtitle: Text('5 questions'),
          ),
          ListTile(
            leading: Icon(Icons.extension_rounded, color: LearnyColors.purple),
            title: Text('Matching pairs'),
            subtitle: Text('3 rounds'),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.packSession),
        child: const Text('Start Session'),
      ),
    );
  }
}
