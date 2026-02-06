import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import 'pressable_scale.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final content = Container(
      padding: padding ?? EdgeInsets.all(tokens.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        border: Border.all(
          color: accentColor?.withValues(alpha: 0.25) ?? LearnyColors.neutralSoft,
          width: accentColor != null ? 1.5 : 1,
        ),
        boxShadow: tokens.cardShadow,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return PressableScale(
      onTap: onTap,
      child: content,
    );
  }
}
