import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/pressable_scale.dart';

class ProgressOverviewScreen extends StatelessWidget {
  const ProgressOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tokens = context.tokens;
    final mastery = state.mastery;
    final overallMastery = mastery.isEmpty
        ? 0.0
        : mastery.values.reduce((a, b) => a + b) / mastery.length;

    return Container(
      decoration: BoxDecoration(gradient: tokens.gradientWelcome),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.spaceLg),
          children: [
            // Header
            FadeInSlide(
              child: Row(
                children: [
                  PressableScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: tokens.radiusMd,
                        boxShadow: tokens.cardShadow,
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: LearnyColors.neutralDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: LearnyColors.neutralDark,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Stats row
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.zap,
                      iconColor: LearnyColors.sunshine,
                      label: 'XP Today',
                      value: '${state.xpToday}',
                      bgColor: LearnyColors.sunshineLight,
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.flame,
                      iconColor: LearnyColors.coral,
                      label: 'Day Streak',
                      value: '${state.streakDays}',
                      bgColor: LearnyColors.coralLight,
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.target,
                      iconColor: LearnyColors.mintPrimary,
                      label: 'Mastery',
                      value: '${(overallMastery * 100).round()}%',
                      bgColor: LearnyColors.mintLight,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Weekly activity chart
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: _WeeklyActivityCard(
                learningTimes: state.learningTimes,
                weeklySummary: state.weeklySummary,
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Topic mastery section
            FadeInSlide(
              delay: const Duration(milliseconds: 300),
              child: _TopicMasteryCard(mastery: mastery),
            ),

            SizedBox(height: tokens.spaceLg),

            // Weak areas section
            if (state.weakAreas.isNotEmpty) ...[
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: _WeakAreasCard(weakAreas: state.weakAreas),
              ),
              SizedBox(height: tokens.spaceLg),
            ],

            // Total XP badge
            FadeInSlide(
              delay: const Duration(milliseconds: 500),
              child: _TotalXpBadge(totalXp: state.totalXp),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LearnyColors.neutralDark,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: LearnyColors.neutralLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard({
    required this.learningTimes,
    required this.weeklySummary,
  });

  final List<dynamic> learningTimes;
  final dynamic weeklySummary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final maxMinutes = learningTimes.isEmpty
        ? 30
        : learningTimes
            .map((t) => t.minutes as int)
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, 120);

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.calendarDays,
                color: LearnyColors.skyPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LearnyColors.neutralDark,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LearnyColors.mintLight,
                  borderRadius: tokens.radiusFull,
                ),
                child: Text(
                  '${weeklySummary.minutesSpent} min',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LearnyColors.mintPrimary,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceLg),

          // Activity bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: learningTimes.map((time) {
              final minutes = time.minutes as int;
              final dayLabel = time.dayLabel as String;
              final heightFactor = minutes / maxMinutes;
              final isToday = dayLabel == 'Today' ||
                  dayLabel == DateTime.now().weekday.toString();

              return _ActivityBar(
                dayLabel: dayLabel.substring(0, 1),
                heightFactor: heightFactor,
                isToday: isToday,
                minutes: minutes,
              );
            }).toList(),
          ),

          SizedBox(height: tokens.spaceMd),

          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                value: '${weeklySummary.sessionsCompleted}',
                label: 'Sessions',
                icon: LucideIcons.gamepad2,
              ),
              _SummaryItem(
                value: '${weeklySummary.newBadges}',
                label: 'Badges',
                icon: LucideIcons.award,
              ),
              _SummaryItem(
                value: weeklySummary.topSubject,
                label: 'Top Subject',
                icon: LucideIcons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityBar extends StatefulWidget {
  const _ActivityBar({
    required this.dayLabel,
    required this.heightFactor,
    required this.isToday,
    required this.minutes,
  });

  final String dayLabel;
  final double heightFactor;
  final bool isToday;
  final int minutes;

  @override
  State<_ActivityBar> createState() => _ActivityBarState();
}

class _ActivityBarState extends State<_ActivityBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 80,
          width: 32,
          child: AnimatedBuilder(
            animation: _heightAnimation,
            builder: (context, _) {
              final animatedHeight =
                  widget.heightFactor * _heightAnimation.value;
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 24,
                  height: math.max(4, 80 * animatedHeight),
                  decoration: BoxDecoration(
                    gradient: widget.isToday
                        ? tokens.gradientAccent
                        : LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              LearnyColors.skyLight,
                              LearnyColors.mintLight,
                            ],
                          ),
                    borderRadius: tokens.radiusMd,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.dayLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: widget.isToday ? FontWeight.w700 : FontWeight.w500,
                color: widget.isToday
                    ? LearnyColors.skyPrimary
                    : LearnyColors.neutralLight,
              ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: LearnyColors.neutralLight, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LearnyColors.neutralDark,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: LearnyColors.neutralLight,
              ),
        ),
      ],
    );
  }
}

class _TopicMasteryCard extends StatelessWidget {
  const _TopicMasteryCard({required this.mastery});

  final Map<String, double> mastery;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final sortedEntries = mastery.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.bookOpen,
                color: LearnyColors.lavender,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Topic Mastery',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LearnyColors.neutralDark,
                    ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          if (sortedEntries.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
              child: Text(
                'Complete some lessons to see your mastery!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LearnyColors.neutralLight,
                    ),
              ),
            )
          else
            ...sortedEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final topic = entry.value.key;
              final progress = entry.value.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < sortedEntries.length - 1 ? tokens.spaceMd : 0,
                ),
                child: _MasteryProgressBar(
                  topic: topic,
                  progress: progress,
                  delay: Duration(milliseconds: 400 + index * 100),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MasteryProgressBar extends StatefulWidget {
  const _MasteryProgressBar({
    required this.topic,
    required this.progress,
    required this.delay,
  });

  final String topic;
  final double progress;
  final Duration delay;

  @override
  State<_MasteryProgressBar> createState() => _MasteryProgressBarState();
}

class _MasteryProgressBarState extends State<_MasteryProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorForProgress(double progress) {
    if (progress >= 0.8) return LearnyColors.mintPrimary;
    if (progress >= 0.5) return LearnyColors.skyPrimary;
    if (progress >= 0.3) return LearnyColors.sunshine;
    return LearnyColors.coral;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = _colorForProgress(widget.progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.topic,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: LearnyColors.neutralDark,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                final animatedPercent =
                    (widget.progress * _progressAnimation.value * 100).round();
                return Text(
                  '$animatedPercent%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: LearnyColors.neutralSoft,
            borderRadius: tokens.radiusFull,
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.progress * _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: tokens.radiusFull,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeakAreasCard extends StatelessWidget {
  const _WeakAreasCard({required this.weakAreas});

  final List<dynamic> weakAreas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.radiusXl,
        boxShadow: tokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: LearnyColors.coralLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.alertCircle,
                  color: LearnyColors.coral,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Areas to Focus',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LearnyColors.neutralDark,
                    ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          ...weakAreas.map((area) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: EdgeInsets.all(tokens.spaceMd),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F7),
                  borderRadius: tokens.radiusLg,
                  border: Border.all(
                    color: LearnyColors.coral.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.title,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: LearnyColors.neutralDark,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            area.note,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: LearnyColors.neutralLight,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      color: LearnyColors.coral.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TotalXpBadge extends StatefulWidget {
  const _TotalXpBadge({required this.totalXp});

  final int totalXp;

  @override
  State<_TotalXpBadge> createState() => _TotalXpBadgeState();
}

class _TotalXpBadgeState extends State<_TotalXpBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _level => (widget.totalXp / 100).floor() + 1;
  int get _xpInLevel => widget.totalXp % 100;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: 0.8 + 0.2 * _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(tokens.spaceLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFF4E1),
                    const Color(0xFFFFE4BC),
                  ],
                ),
                borderRadius: tokens.radiusXl,
                boxShadow: [
                  BoxShadow(
                    color: LearnyColors.sunshine.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: LearnyColors.sunshine.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_level',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: LearnyColors.sunshine,
                                ),
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $_level Learner',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: LearnyColors.neutralDark,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.sparkles,
                              color: LearnyColors.sunshine,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.totalXp} XP total',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: LearnyColors.neutralMedium,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // XP progress to next level
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: tokens.radiusFull,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _xpInLevel / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: LearnyColors.sunshine,
                                borderRadius: tokens.radiusFull,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${100 - _xpInLevel} XP to Level ${_level + 1}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: LearnyColors.neutralLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
