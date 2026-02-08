import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final games = _gamesFromState(state, context);
    return PlaceholderScreen(
      title: pack?.title ?? L10n.of(context).packDetailDefaultTitle,
      subtitle: pack == null
          ? L10n.of(context).packDetailNoPack
          : '${pack.itemCount} cards • ${games.length} games • ${pack.minutes} minutes',
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: games.isEmpty
            ? [
                ListTile(
                  leading: const Icon(Icons.hourglass_empty_rounded),
                  title: Text(L10n.of(context).packDetailNoGamesTitle),
                  subtitle: Text(
                    L10n.of(context).packDetailNoGamesMessage,
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
        child: Text(L10n.of(context).packDetailStartSession),
      ),
    );
  }

  List<_GameDetailItem> _gamesFromState(AppState state, BuildContext context) {
    final queue = state.packGameQueue.isNotEmpty
        ? state.packGameQueue
        : state.gamePayloads.keys.toList();
    return queue
        .map(
          (type) => _GameDetailItem(
            label: _labelForType(type, context),
            subtitle: _subtitleForType(type, context),
            icon: _iconForType(type),
            color: _colorForType(type),
          ),
        )
        .toList();
  }

  String _labelForType(String type, BuildContext context) {
    switch (type) {
      case 'true_false':
        return L10n.of(context).gameTypeTrueFalse;
      case 'multiple_select':
        return L10n.of(context).gameTypeMultiSelect;
      case 'fill_blank':
        return L10n.of(context).gameTypeFillBlank;
      case 'short_answer':
        return L10n.of(context).gameTypeShortAnswer;
      case 'ordering':
        return L10n.of(context).gameTypeOrdering;
      case 'matching':
        return L10n.of(context).gameTypeMatching;
      case 'flashcards':
        return L10n.of(context).gameTypeFlashcards;
      case 'quiz':
      default:
        return L10n.of(context).gameTypeQuiz;
    }
  }

  String _subtitleForType(String type, BuildContext context) {
    switch (type) {
      case 'true_false':
        return L10n.of(context).gameSubtitleTrueFalse;
      case 'multiple_select':
        return L10n.of(context).gameSubtitleMultiSelect;
      case 'fill_blank':
        return L10n.of(context).gameSubtitleFillBlank;
      case 'short_answer':
        return L10n.of(context).gameSubtitleShortAnswer;
      case 'ordering':
        return L10n.of(context).gameSubtitleOrdering;
      case 'matching':
        return L10n.of(context).gameSubtitleMatching;
      case 'flashcards':
        return L10n.of(context).gameSubtitleFlashcards;
      case 'quiz':
      default:
        return L10n.of(context).gameSubtitleQuiz;
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
