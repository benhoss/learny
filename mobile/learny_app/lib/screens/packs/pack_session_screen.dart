import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class PackSessionScreen extends StatelessWidget {
  const PackSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final pack =
        state.selectedPack ??
        (state.packs.isNotEmpty ? state.packs.first : null);
    final games = _sessionGames(state, context);
    return PlaceholderScreen(
      title: pack == null
          ? L10n.of(context).packSessionDefaultTitle
          : '${pack.title} Session',
      subtitle: L10n.of(context).packSessionSubtitle(pack?.minutes ?? 15),
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: games.isEmpty
            ? [
                ListTile(
                  leading: const Icon(Icons.hourglass_empty_rounded),
                  title: Text(L10n.of(context).packSessionNoGamesTitle),
                  subtitle: Text(
                    L10n.of(context).packSessionNoGamesMessage,
                  ),
                ),
              ]
            : List.generate(games.length, (index) {
                final item = games[index];
                return ListTile(
                  leading: Icon(_stepIcon(index), color: item.color),
                  title: Text(item.label),
                  subtitle: Text(item.subtitle),
                );
              }),
      ),
      primaryAction: ElevatedButton(
        onPressed: () async {
          await state.startPackSession(packId: pack?.id);
          if (!context.mounted) {
            return;
          }
          final firstType = state.currentPackGameType;
          if (firstType == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  L10n.of(context).packSessionNoGamesSnackBar,
                ),
              ),
            );
            return;
          }
          state.startGameType(firstType);
          Navigator.pushNamed(context, state.routeForGameType(firstType));
        },
        child: Text(L10n.of(context).packSessionStartNow),
      ),
    );
  }

  List<_SessionGameItem> _sessionGames(AppState state, BuildContext context) {
    final queue = state.packGameQueue.isNotEmpty
        ? state.packGameQueue
        : state.gamePayloads.keys.toList();
    return queue
        .map(
          (type) => _SessionGameItem(
            label: _labelForType(type, context),
            subtitle: _subtitleForType(type, context),
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

  IconData _stepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.looks_one_rounded;
      case 1:
        return Icons.looks_two_rounded;
      case 2:
        return Icons.looks_3_rounded;
      case 3:
        return Icons.looks_4_rounded;
      case 4:
        return Icons.looks_5_rounded;
      case 5:
        return Icons.looks_6_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}

class _SessionGameItem {
  const _SessionGameItem({
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String subtitle;
  final Color color;
}
