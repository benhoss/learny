import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
    this.showLabel = false,
  });

  final double progress;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final clamped = progress.clamp(0, 100) / 100;
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: LearnyColors.neutralSoft,
                borderRadius: tokens.radiusFull,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: tokens.baseDuration,
                  curve: Curves.easeOut,
                  width: width * clamped,
                  constraints: const BoxConstraints(minWidth: 12),
                  decoration: BoxDecoration(
                    gradient: tokens.gradientAccent,
                    borderRadius: tokens.radiusFull,
                  ),
                ),
              ),
            );
          },
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Text(
            '${progress.round()}% complete',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: LearnyColors.neutralLight),
          ),
        ],
      ],
    );
  }
}
