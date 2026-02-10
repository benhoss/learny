import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import 'progress_bar.dart';
import 'timer_badge.dart';
import 'streak_pill.dart';
import 'mastery_meter.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.title,
    required this.progress,
    this.subtitle,
    this.timerSeconds,
    this.timerSeed,
    required this.streakCount,
    required this.masteryPercent,
  });

  final String title;
  final String? subtitle;
  final double progress;
  final int? timerSeconds;
  final int? timerSeed;
  final int streakCount;
  final double masteryPercent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 18,
              color: LearnyColors.skyPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: LearnyColors.neutralMedium),
          ),
        ],
        SizedBox(height: tokens.spaceMd),
        ProgressBar(progress: progress),
        SizedBox(height: tokens.spaceSm),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (timerSeconds != null)
              TimerBadge(
                key: timerSeed == null ? null : ValueKey(timerSeed),
                seconds: timerSeconds!,
              ),
            StreakPill(count: streakCount),
            MasteryMeter(percent: masteryPercent),
          ],
        ),
      ],
    );
  }
}
