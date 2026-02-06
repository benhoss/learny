import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';

class MasteryMeter extends StatelessWidget {
  const MasteryMeter({
    super.key,
    required this.percent,
  });

  final double percent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final clamped = percent.clamp(0, 1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LearnyColors.lavender.withValues(alpha: 0.2),
        borderRadius: tokens.radiusFull,
        border: Border.all(color: LearnyColors.lavender.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.barChart3,
            size: 14,
            color: LearnyColors.lavender,
          ),
          const SizedBox(width: 6),
          Text(
            'Mastery ${(clamped * 100).round()}%',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: LearnyColors.lavender, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
