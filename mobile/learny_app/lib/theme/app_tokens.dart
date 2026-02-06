import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class LearnyTokens extends ThemeExtension<LearnyTokens> {
  const LearnyTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.space2xl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
    required this.cardShadow,
    required this.cardHoverShadow,
    required this.buttonShadow,
    required this.buttonHoverShadow,
    required this.gradientWelcome,
    required this.gradientCard,
    required this.gradientAccent,
    required this.microDuration,
    required this.baseDuration,
    required this.transitionDuration,
  });

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double space2xl;

  final BorderRadius radiusSm;
  final BorderRadius radiusMd;
  final BorderRadius radiusLg;
  final BorderRadius radiusXl;
  final BorderRadius radiusFull;

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> cardHoverShadow;
  final List<BoxShadow> buttonShadow;
  final List<BoxShadow> buttonHoverShadow;

  final LinearGradient gradientWelcome;
  final LinearGradient gradientCard;
  final LinearGradient gradientAccent;

  final Duration microDuration;
  final Duration baseDuration;
  final Duration transitionDuration;

  static const LearnyTokens light = LearnyTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    space2xl: 48,
    radiusSm: BorderRadius.all(Radius.circular(8)),
    radiusMd: BorderRadius.all(Radius.circular(12)),
    radiusLg: BorderRadius.all(Radius.circular(16)),
    radiusXl: BorderRadius.all(Radius.circular(24)),
    radiusFull: BorderRadius.all(Radius.circular(9999)),
    cardShadow: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 20,
        offset: Offset(0, 12),
      ),
    ],
    cardHoverShadow: [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 30,
        offset: Offset(0, 16),
      ),
    ],
    buttonShadow: [
      BoxShadow(
        color: Color(0x4D7DD3E8),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
    buttonHoverShadow: [
      BoxShadow(
        color: Color(0x667DD3E8),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
    gradientWelcome: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE8F7FA),
        Color(0xFFFFF8F0),
      ],
    ),
    gradientCard: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFF7F9FC),
      ],
    ),
    gradientAccent: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7DD3E8),
        Color(0xFF8FE5C2),
      ],
    ),
    microDuration: Duration(milliseconds: 150),
    baseDuration: Duration(milliseconds: 300),
    transitionDuration: Duration(milliseconds: 400),
  );

  @override
  LearnyTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? space2xl,
    BorderRadius? radiusSm,
    BorderRadius? radiusMd,
    BorderRadius? radiusLg,
    BorderRadius? radiusXl,
    BorderRadius? radiusFull,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? cardHoverShadow,
    List<BoxShadow>? buttonShadow,
    List<BoxShadow>? buttonHoverShadow,
    LinearGradient? gradientWelcome,
    LinearGradient? gradientCard,
    LinearGradient? gradientAccent,
    Duration? microDuration,
    Duration? baseDuration,
    Duration? transitionDuration,
  }) {
    return LearnyTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      space2xl: space2xl ?? this.space2xl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusFull: radiusFull ?? this.radiusFull,
      cardShadow: cardShadow ?? this.cardShadow,
      cardHoverShadow: cardHoverShadow ?? this.cardHoverShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      buttonHoverShadow: buttonHoverShadow ?? this.buttonHoverShadow,
      gradientWelcome: gradientWelcome ?? this.gradientWelcome,
      gradientCard: gradientCard ?? this.gradientCard,
      gradientAccent: gradientAccent ?? this.gradientAccent,
      microDuration: microDuration ?? this.microDuration,
      baseDuration: baseDuration ?? this.baseDuration,
      transitionDuration: transitionDuration ?? this.transitionDuration,
    );
  }

  @override
  LearnyTokens lerp(ThemeExtension<LearnyTokens>? other, double t) {
    if (other is! LearnyTokens) {
      return this;
    }
    return LearnyTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t) ?? spaceXs,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t) ?? spaceSm,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t) ?? spaceMd,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t) ?? spaceLg,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t) ?? spaceXl,
      space2xl: lerpDouble(space2xl, other.space2xl, t) ?? space2xl,
      radiusSm: BorderRadius.lerp(radiusSm, other.radiusSm, t) ?? radiusSm,
      radiusMd: BorderRadius.lerp(radiusMd, other.radiusMd, t) ?? radiusMd,
      radiusLg: BorderRadius.lerp(radiusLg, other.radiusLg, t) ?? radiusLg,
      radiusXl: BorderRadius.lerp(radiusXl, other.radiusXl, t) ?? radiusXl,
      radiusFull: BorderRadius.lerp(radiusFull, other.radiusFull, t) ?? radiusFull,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      cardHoverShadow: t < 0.5 ? cardHoverShadow : other.cardHoverShadow,
      buttonShadow: t < 0.5 ? buttonShadow : other.buttonShadow,
      buttonHoverShadow: t < 0.5 ? buttonHoverShadow : other.buttonHoverShadow,
      gradientWelcome: LinearGradient.lerp(gradientWelcome, other.gradientWelcome, t) ??
          gradientWelcome,
      gradientCard: LinearGradient.lerp(gradientCard, other.gradientCard, t) ?? gradientCard,
      gradientAccent: LinearGradient.lerp(gradientAccent, other.gradientAccent, t) ??
          gradientAccent,
      microDuration: t < 0.5 ? microDuration : other.microDuration,
      baseDuration: t < 0.5 ? baseDuration : other.baseDuration,
      transitionDuration: t < 0.5 ? transitionDuration : other.transitionDuration,
    );
  }
}

extension LearnyTokensX on BuildContext {
  LearnyTokens get tokens => Theme.of(this).extension<LearnyTokens>() ?? LearnyTokens.light;
}
