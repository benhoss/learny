import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import 'game_card.dart';

class ResultSummaryCard extends StatelessWidget {
  const ResultSummaryCard({
    super.key,
    required this.correct,
    required this.total,
    required this.streak,
    required this.masteryDelta,
  });

  final int correct;
  final int total;
  final int streak;
  final int masteryDelta;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accuracy = total == 0 ? 0 : (correct / total * 100).round();
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$accuracy%',
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.w700, color: LearnyColors.skyPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '$correct of $total correct',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: LearnyColors.neutralMedium),
          ),
          SizedBox(height: tokens.spaceMd),
          Wrap(
            spacing: tokens.spaceLg,
            runSpacing: tokens.spaceSm,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _Metric(
                icon: LucideIcons.flame,
                label: 'Streak',
                value: '$streak days',
                color: LearnyColors.coral,
              ),
              _Metric(
                icon: LucideIcons.barChart3,
                label: 'Mastery',
                value: masteryDelta >= 0 ? '+$masteryDelta%' : '$masteryDelta%',
                color: LearnyColors.lavender,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: LearnyColors.neutralLight),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
