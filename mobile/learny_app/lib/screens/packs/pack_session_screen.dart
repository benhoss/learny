import 'package:flutter/material.dart';
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
    final games = _sessionGames(state);
    return PlaceholderScreen(
      title: pack == null ? 'Session Roadmap' : '${pack.title} Session',
      subtitle: pack == null
          ? '15-minute guided flow.'
          : '${pack.minutes} minute guided flow.',
      gradient: LearnyGradients.trust,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: games.isEmpty
            ? const [
                ListTile(
                  leading: Icon(Icons.hourglass_empty_rounded),
                  title: Text('No ready games'),
                  subtitle: Text(
                    'Finish document processing, then start the session.',
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
              const SnackBar(
                content: Text(
                  'No generated games are ready for this pack yet.',
                ),
              ),
            );
            return;
          }
          state.startGameType(firstType);
          Navigator.pushNamed(context, state.routeForGameType(firstType));
        },
        child: const Text('Start Now'),
      ),
    );
  }

  List<_SessionGameItem> _sessionGames(AppState state) {
    final queue = state.packGameQueue.isNotEmpty
        ? state.packGameQueue
        : state.gamePayloads.keys.toList();
    return queue
        .map(
          (type) => _SessionGameItem(
            label: _labelForType(type),
            subtitle: _subtitleForType(type),
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
        return 'Matching';
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
        return 'Pick every correct answer';
      case 'fill_blank':
        return 'Complete the sentence';
      case 'short_answer':
        return 'Type a short response';
      case 'ordering':
        return 'Arrange in order';
      case 'matching':
        return 'Match pairs';
      case 'flashcards':
        return 'Warm-up cards';
      case 'quiz':
      default:
        return 'Multiple choice';
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
