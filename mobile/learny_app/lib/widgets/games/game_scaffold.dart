import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';

class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.showDecorations = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool showDecorations;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: appBar,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: tokens.gradientWelcome),
        child: SafeArea(
          child: Stack(
            children: [
              if (showDecorations) ...[
                Positioned(
                  top: -40,
                  right: -20,
                  child: _GlowCircle(
                    size: 140,
                    color: LearnyColors.skyPrimary.withValues(alpha: 0.2),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -40,
                  child: _GlowCircle(
                    size: 180,
                    color: LearnyColors.mintPrimary.withValues(alpha: 0.18),
                  ),
                ),
              ],
              AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  left: tokens.spaceLg,
                  right: tokens.spaceLg,
                  top: tokens.spaceLg,
                  bottom:
                      tokens.spaceLg + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
