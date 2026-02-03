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
    final games = _defaultGames();
    return PlaceholderScreen(
      title: pack?.title ?? 'Learning Pack',
      subtitle: pack == null
          ? 'No pack selected yet.'
          : '${pack.itemCount} cards • ${games.length} games • ${pack.minutes} minutes',
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: games
            .map(
              (game) => ListTile(
                leading: Icon(game.icon, color: game.color),
                title: Text(game.label),
                subtitle: Text(game.subtitle),
              ),
            )
            .toList(),
      ),
      primaryAction: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.packSession),
        child: const Text('Start Session'),
      ),
    );
  }

  List<_GameDetailItem> _defaultGames() {
    return const [
      _GameDetailItem(
        label: 'Warm-up flashcards',
        subtitle: '10 cards',
        icon: Icons.flash_on_rounded,
        color: LearnyColors.coral,
      ),
      _GameDetailItem(
        label: 'Quick quiz',
        subtitle: '5 questions',
        icon: Icons.quiz_rounded,
        color: LearnyColors.teal,
      ),
      _GameDetailItem(
        label: 'True or False',
        subtitle: 'Fast judgments',
        icon: Icons.rule_rounded,
        color: LearnyColors.coralLight,
      ),
      _GameDetailItem(
        label: 'Fill in the Blank',
        subtitle: 'Complete the sentence',
        icon: Icons.edit_rounded,
        color: LearnyColors.coralLight,
      ),
      _GameDetailItem(
        label: 'Choose All That Apply',
        subtitle: 'Multiple correct answers',
        icon: Icons.checklist_rounded,
        color: LearnyColors.coralLight,
      ),
      _GameDetailItem(
        label: 'Short Answer',
        subtitle: 'Write a quick response',
        icon: Icons.short_text_rounded,
        color: LearnyColors.coralLight,
      ),
      _GameDetailItem(
        label: 'Ordering Challenge',
        subtitle: 'Drag into order',
        icon: Icons.reorder_rounded,
        color: LearnyColors.coralLight,
      ),
      _GameDetailItem(
        label: 'Matching pairs',
        subtitle: '3 rounds',
        icon: Icons.extension_rounded,
        color: LearnyColors.purple,
      ),
    ];
  }
}

class _GameDetailItem {
  const _GameDetailItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
}
