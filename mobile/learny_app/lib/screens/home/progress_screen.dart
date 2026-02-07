import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const List<String> _supportedGameTypes = [
    'flashcards',
    'quiz',
    'matching',
    'true_false',
    'fill_blank',
    'ordering',
    'multiple_select',
    'short_answer',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final masteryValues = state.mastery.values.toList();
    final masteryAverage = masteryValues.isEmpty
        ? 0.0
        : masteryValues.reduce((a, b) => a + b) / masteryValues.length;
    final recentActivities = state.activities;
    final recentCount = recentActivities.length;
    final averageScore = recentCount == 0
        ? 0
        : (recentActivities
                      .map((activity) => activity.scorePercent)
                      .reduce((a, b) => a + b) /
                  recentCount)
              .round();
    final recentXp = recentActivities.fold<int>(
      0,
      (sum, activity) => sum + activity.xpEarned,
    );
    final latestCheer = recentActivities.isEmpty
        ? 'Upload a document and complete a game to start your momentum.'
        : recentActivities.first.cheerMessage;
    final momentumLabel = averageScore >= 85
        ? 'Excellent momentum'
        : averageScore >= 65
        ? 'Steady momentum'
        : recentCount == 0
        ? 'Ready to start'
        : 'Building momentum';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Progress',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Past results, trends, and what to redo next.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: LearnyColors.slateMedium),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    momentumLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(label: 'Sessions', value: '$recentCount'),
                  _MetricChip(label: 'Avg score', value: '$averageScore%'),
                  _MetricChip(label: 'Recent XP', value: '+$recentXp'),
                  _MetricChip(label: 'Streak', value: '${state.streakDays}d'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                latestCheer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LearnyColors.slateMedium,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Progress'),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: masteryAverage),
              const SizedBox(height: 8),
              Text(
                '${(masteryAverage * 100).round()}% mastery across this week\'s packs',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PastActivitySection(
          state: state,
          supportedGameTypes: _supportedGameTypes,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _ActionCard(
              label: 'Mastery Details',
              route: AppRoutes.masteryDetail,
              icon: Icons.track_changes_rounded,
            ),
            _ActionCard(
              label: 'Streaks & Rewards',
              route: AppRoutes.streaksRewards,
              icon: Icons.local_fire_department_rounded,
            ),
            _ActionCard(
              label: 'Achievements',
              route: AppRoutes.achievements,
              icon: Icons.emoji_events_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.progressOverview),
          child: const Text('Open Progress Overview'),
        ),
      ],
    );
  }
}

class _PastActivitySection extends StatelessWidget {
  const _PastActivitySection({
    required this.state,
    required this.supportedGameTypes,
  });

  final AppState state;
  final List<String> supportedGameTypes;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Past Activity',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => state.refreshActivitiesFromBackend(),
                child: const Text('Refresh'),
              ),
            ],
          ),
          if (state.isSyncingActivities)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (state.activitySyncError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.activitySyncError!,
                style: const TextStyle(color: LearnyColors.coral),
              ),
            ),
          if (state.activities.isEmpty)
            const ListTile(
              leading: Icon(Icons.history_rounded),
              title: Text('No activity yet'),
              subtitle: Text(
                'Play a generated game to see results and motivation here.',
              ),
            )
          else
            ...state.activities.map(
              (activity) => _ActivityCard(
                title: activity.subject,
                subtitle:
                    '${_formatDate(activity.completedAt)} • ${_labelForGameType(activity.gameType)}',
                scorePercent: activity.scorePercent,
                scoreLabel:
                    '${activity.correctAnswers}/${activity.totalQuestions} correct',
                progressionDelta: activity.progressionDelta,
                cheerMessage: activity.cheerMessage,
                xpEarned: activity.xpEarned,
                onRedoSubject: activity.packId == null
                    ? null
                    : () => _redoSubject(context, state, activity.packId!),
                onRedoDocument: activity.documentId == null
                    ? null
                    : () => _redoDocument(context, state, activity.documentId!),
                onGenerateNewType: activity.documentId == null
                    ? null
                    : () => _generateNewGameType(
                        context,
                        state,
                        activity.documentId!,
                        activity.remainingGameTypes.isNotEmpty
                            ? activity.remainingGameTypes
                            : supportedGameTypes,
                      ),
              ),
            ),
          if (state.activities.isNotEmpty && state.hasMoreActivities)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: state.isSyncingActivities
                    ? null
                    : () => state.loadMoreActivitiesFromBackend(),
                child: const Text('Load older activity'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _redoSubject(
    BuildContext context,
    AppState state,
    String packId,
  ) async {
    try {
      await state.startPackSession(packId: packId);
      if (!context.mounted) {
        return;
      }
      final firstType = state.currentPackGameType;
      if (firstType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No ready games found for this subject yet.'),
          ),
        );
        return;
      }
      state.startGameType(firstType);
      Navigator.pushNamed(context, state.routeForGameType(firstType));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not reopen this subject: $error')),
      );
    }
  }

  Future<void> _redoDocument(
    BuildContext context,
    AppState state,
    String documentId,
  ) async {
    final ok = await state.regenerateDocument(documentId);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Document regeneration started.'
              : 'Could not regenerate document right now.',
        ),
      ),
    );
  }

  Future<void> _generateNewGameType(
    BuildContext context,
    AppState state,
    String documentId,
    List<String> gameTypes,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text('Generate New Game Type'),
                subtitle: Text(
                  'Choose a type to regenerate from this document',
                ),
              ),
              ...gameTypes.map(
                (type) => ListTile(
                  title: Text(_labelForGameType(type)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(context, type),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || selected.isEmpty) {
      return;
    }

    final ok = await state.regenerateDocument(
      documentId,
      requestedGameTypes: [selected],
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Regeneration started for ${_labelForGameType(selected)}.'
              : 'Could not start regeneration for ${_labelForGameType(selected)}.',
        ),
      ),
    );
  }

  static String _labelForGameType(String type) {
    switch (type) {
      case 'true_false':
        return 'True or False';
      case 'multiple_select':
        return 'Multiple Select';
      case 'fill_blank':
        return 'Fill in the Blank';
      case 'short_answer':
        return 'Short Answer';
      case 'ordering':
        return 'Ordering';
      case 'flashcards':
        return 'Flashcards';
      case 'matching':
        return 'Matching';
      case 'quiz':
      default:
        return 'Quiz';
    }
  }

  static String _formatDate(DateTime dateTime) {
    final date = dateTime.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }
}

class _ActivityCard extends StatefulWidget {
  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.scorePercent,
    required this.scoreLabel,
    required this.cheerMessage,
    required this.xpEarned,
    this.progressionDelta,
    this.onRedoSubject,
    this.onRedoDocument,
    this.onGenerateNewType,
  });

  final String title;
  final String subtitle;
  final int scorePercent;
  final String scoreLabel;
  final int? progressionDelta;
  final String cheerMessage;
  final int xpEarned;
  final Future<void> Function()? onRedoSubject;
  final Future<void> Function()? onRedoDocument;
  final Future<void> Function()? onGenerateNewType;

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _isBusy = false;

  Future<void> _runAction(Future<void> Function()? action) async {
    if (_isBusy || action == null) {
      return;
    }
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final delta = widget.progressionDelta;
    final deltaColor = (delta ?? 0) >= 0
        ? LearnyColors.teal
        : LearnyColors.coral;
    final deltaLabel = delta == null
        ? 'New'
        : delta >= 0
        ? '+$delta%'
        : '$delta%';
    final scoreBand = _scoreBand(widget.scorePercent);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: LearnyColors.slateMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: deltaColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    deltaLabel,
                    style: TextStyle(
                      color: deltaColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreBand.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    scoreBand.label,
                    style: TextStyle(
                      color: scoreBand.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (widget.scorePercent.clamp(0, 100)) / 100,
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.scorePercent}% • ${widget.scoreLabel} • +${widget.xpEarned} XP',
            ),
            const SizedBox(height: 6),
            Text(
              widget.cheerMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: LearnyColors.slateMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _isBusy || widget.onRedoSubject == null
                      ? null
                      : () => _runAction(widget.onRedoSubject),
                  child: const Text('Redo Subject'),
                ),
                OutlinedButton(
                  onPressed: _isBusy || widget.onRedoDocument == null
                      ? null
                      : () => _runAction(widget.onRedoDocument),
                  child: const Text('Redo Document'),
                ),
                OutlinedButton(
                  onPressed: _isBusy || widget.onGenerateNewType == null
                      ? null
                      : () => _runAction(widget.onGenerateNewType),
                  child: const Text('New Game Type'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _ScoreBand _scoreBand(int scorePercent) {
    if (scorePercent >= 85) {
      return const _ScoreBand(label: 'Strong', color: LearnyColors.teal);
    }
    if (scorePercent >= 65) {
      return const _ScoreBand(
        label: 'Improving',
        color: LearnyColors.skyPrimary,
      );
    }
    return const _ScoreBand(label: 'Keep Going', color: LearnyColors.sunshine);
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.pushNamed(context, route),
      child: Ink(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: LearnyColors.coral),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: LearnyColors.neutralCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: LearnyColors.slateMedium),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ScoreBand {
  const _ScoreBand({required this.label, required this.color});

  final String label;
  final Color color;
}
