import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final pack =
        state.selectedPack ??
        (state.packs.isNotEmpty ? state.packs.first : null);
    final games = _gamesFromState(state);
    return PlaceholderScreen(
      title: pack?.title ?? 'Learning Pack',
      subtitle: pack == null
          ? 'No pack selected yet.'
          : '${pack.itemCount} cards • ${games.length} games • ${pack.minutes} minutes',
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: games.isEmpty
            ? const [
                ListTile(
                  leading: Icon(Icons.hourglass_empty_rounded),
                  title: Text('No generated games yet'),
                  subtitle: Text(
                    'Upload or regenerate this document to create games.',
                  ),
                ),
              ]
            : games
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

  List<_GameDetailItem> _gamesFromState(AppState state) {
    final queue = state.packGameQueue.isNotEmpty
        ? state.packGameQueue
        : state.gamePayloads.keys.toList();
    return queue
        .map(
          (type) => _GameDetailItem(
            label: _labelForType(type),
            subtitle: _subtitleForType(type),
            icon: _iconForType(type),
            color: _colorForType(type),
          ),
        )
        .toList();
  }

  String _labelForType(String type) {
    switch (type) {
      case 'true_false':
        return 'True or False';
      case 'multiple_select':
        return 'Choose All That Apply';
      case 'fill_blank':
        return 'Fill in the Blank';
      case 'short_answer':
        return 'Short Answer';
      case 'ordering':
        return 'Ordering Challenge';
      case 'matching':
        return 'Matching Pairs';
      case 'flashcards':
        return 'Flashcards';
      case 'quiz':
      default:
        return 'Quiz';
    }
  }

  String _subtitleForType(String type) {
    switch (type) {
      case 'true_false':
        return 'Quick judgments';
      case 'multiple_select':
        return 'Multiple correct answers';
      case 'fill_blank':
        return 'Complete the sentence';
      case 'short_answer':
        return 'Write a quick response';
      case 'ordering':
        return 'Drag items into order';
      case 'matching':
        return 'Match linked concepts';
      case 'flashcards':
        return 'Warm-up concepts';
      case 'quiz':
      default:
        return 'Multiple choice questions';
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'flashcards':
        return Icons.flash_on_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'true_false':
        return Icons.rule_rounded;
      case 'fill_blank':
        return Icons.edit_rounded;
      case 'multiple_select':
        return Icons.checklist_rounded;
      case 'short_answer':
        return Icons.short_text_rounded;
      case 'ordering':
        return Icons.reorder_rounded;
      case 'matching':
        return Icons.extension_rounded;
      default:
        return Icons.gamepad_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'flashcards':
        return LearnyColors.coral;
      case 'quiz':
        return LearnyColors.teal;
      case 'matching':
        return LearnyColors.purple;
      default:
        return LearnyColors.coralLight;
    }
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
