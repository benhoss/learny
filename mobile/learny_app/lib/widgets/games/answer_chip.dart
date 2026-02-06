import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import 'pressable_scale.dart';

class AnswerChip extends StatelessWidget {
  const AnswerChip({
    super.key,
    required this.text,
    this.isSelected = false,
    this.isCorrect,
    this.showResult = false,
    this.onTap,
  });

  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final bool showResult;
  final VoidCallback? onTap;

  Color _borderColor() {
    if (showResult && isCorrect == true) {
      return LearnyColors.success;
    }
    if (showResult && isCorrect == false && isSelected) {
      return LearnyColors.coral;
    }
    if (isSelected) {
      return LearnyColors.skyPrimary;
    }
    return LearnyColors.neutralSoft;
  }

  Color _backgroundColor() {
    if (showResult && isCorrect == true) {
      return LearnyColors.success.withValues(alpha: 0.15);
    }
    if (showResult && isCorrect == false && isSelected) {
      return LearnyColors.coral.withValues(alpha: 0.12);
    }
    if (isSelected) {
      return LearnyColors.skyLight.withValues(alpha: 0.4);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spaceMd,
        vertical: tokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: tokens.radiusLg,
        border: Border.all(color: _borderColor(), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: LearnyColors.neutralDark,
                  ),
            ),
          ),
          // Animated checkmark for correct answers
          if (showResult && isCorrect == true)
            _AnimatedCheckmark()
          else if (showResult && isCorrect == false && isSelected)
            _AnimatedCross(),
        ],
      ),
    );

    if (onTap == null || showResult) {
      return content;
    }

    return PressableScale(onTap: onTap, child: content);
  }
}

class _AnimatedCheckmark extends StatefulWidget {
  @override
  State<_AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<_AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: LearnyColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.check,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _AnimatedCross extends StatefulWidget {
  @override
  State<_AnimatedCross> createState() => _AnimatedCrossState();
}

class _AnimatedCrossState extends State<_AnimatedCross>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: LearnyColors.coral.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.x,
          color: LearnyColors.coral,
          size: 16,
        ),
      ),
    );
  }
}
