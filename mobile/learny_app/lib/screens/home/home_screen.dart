import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/learning_pack.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';
import '../../state/app_state_scope.dart';
import '../../widgets/animations/fade_in_slide.dart';
import '../../widgets/games/pressable_scale.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.profile;
    final tokens = context.tokens;
    final featuredPacks = state.packs.take(2).toList();
    final recommendations = state.homeRecommendations.take(3).toList();
    final smartNextSteps = recommendations;

    return Container(
      decoration: BoxDecoration(gradient: tokens.gradientWelcome),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.spaceLg),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LearnyColors.neutralLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hi ${profile.name}! 👋',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: LearnyColors.neutralDark,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: tokens.gradientAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.sparkles,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),

            SizedBox(height: tokens.spaceLg),

            // Welcome message card with blur effect
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: ClipRRect(
                borderRadius: tokens.radiusXl,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: EdgeInsets.all(tokens.spaceMd + 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: tokens.radiusXl,
                    ),
                    child: Text(
                      'Ready to learn something new today? Let\'s turn your school lessons into fun games!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: LearnyColors.neutralMedium,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Primary CTA: Start Learning
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: _PrimaryActionCard(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.cameraCapture),
                icon: LucideIcons.bookOpen,
                title: 'Start Learning',
                subtitle: 'Upload your lesson and play',
              ),
            ),

            SizedBox(height: tokens.spaceMd),

            // Secondary CTA: Revision Express
            FadeInSlide(
              delay: const Duration(milliseconds: 300),
              child: _SecondaryActionCard(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.revisionSetup),
                icon: LucideIcons.zap,
                title: 'Revision Express',
                subtitle: 'Quick 5-minute review',
              ),
            ),

            // Review prompt (shown when concepts are due)
            if (state.reviewDueCount > 0) ...[
              SizedBox(height: tokens.spaceMd),
              FadeInSlide(
                delay: const Duration(milliseconds: 350),
                child: _ReviewCard(
                  dueCount: state.reviewDueCount,
                  onTap: () {
                    () async {
                      final route = await state.startReviewFromDueConcepts();
                      if (!context.mounted) {
                        return;
                      }
                      if (route != null) {
                        Navigator.pushNamed(context, route);
                        return;
                      }
                      Navigator.pushNamed(context, AppRoutes.revisionSetup);
                    }();
                  },
                ),
              ),
            ],

            SizedBox(height: tokens.spaceMd),
            FadeInSlide(
              delay: const Duration(milliseconds: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Next Steps',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  SizedBox(height: tokens.spaceSm),
                  if (smartNextSteps.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(tokens.spaceMd),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: tokens.radiusLg,
                      ),
                      child: Text(
                        'Upload a document to get AI recommendations based on real study data.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LearnyColors.neutralMedium,
                        ),
                      ),
                    )
                  else
                    ...smartNextSteps.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SmartRecommendationCard(
                          title:
                              item['title']?.toString() ?? 'Continue learning',
                          subtitle:
                              item['subtitle']?.toString() ??
                              'Based on your recent activity',
                          onTap: () async {
                            final route = await state.runRecommendationAction(
                              item,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.pushNamed(context, route);
                          },
                          onWhy: state.recommendationWhyEnabled
                              ? () =>
                                    _showRecommendationWhyDialog(context, item)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Weekly Progress
            FadeInSlide(
              delay: const Duration(milliseconds: 400),
              child: _ProgressCard(sessionsCompleted: state.streakDays),
            ),

            if (featuredPacks.isNotEmpty) ...[
              SizedBox(height: tokens.spaceLg),
              FadeInSlide(
                delay: const Duration(milliseconds: 450),
                child: _PackMasterySection(
                  packs: featuredPacks,
                  onTapPack: (pack) {
                    state.selectPack(pack.id);
                    Navigator.pushNamed(context, AppRoutes.packDetail);
                  },
                ),
              ),
            ],

            SizedBox(height: tokens.spaceLg),

            // Quick access row (simplified)
            FadeInSlide(
              delay: const Duration(milliseconds: 600),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickAccessTile(
                      icon: LucideIcons.trophy,
                      label: 'Achievements',
                      color: LearnyColors.sunshine,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.achievements),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: _QuickAccessTile(
                      icon: LucideIcons.barChart2,
                      label: 'Progress',
                      color: LearnyColors.lavender,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.progressOverview,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecommendationWhyDialog(
    BuildContext context,
    Map<String, dynamic> recommendation,
  ) {
    final explainability = recommendation['explainability'];
    final details = <String>[];
    if (explainability is Map) {
      for (final entry in explainability.entries) {
        details.add('${entry.key}: ${entry.value}');
      }
    }
    if (details.isEmpty) {
      details.add('No additional rationale available for this suggestion.');
    }

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Why this recommendation?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation['title']?.toString() ?? 'Recommendation'),
            const SizedBox(height: 8),
            ...details.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.spaceLg),
        decoration: BoxDecoration(
          gradient: tokens.gradientAccent,
          borderRadius: tokens.radiusXl,
          boxShadow: [
            BoxShadow(
              color: LearnyColors.skyPrimary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: tokens.radiusLg,
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: Colors.white.withValues(alpha: 0.6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartRecommendationCard extends StatelessWidget {
  const _SmartRecommendationCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onWhy,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onWhy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: tokens.radiusLg,
          border: Border.all(
            color: LearnyColors.skyPrimary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: LearnyColors.skyPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: LearnyColors.skyPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: LearnyColors.neutralMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (onWhy != null)
              IconButton(
                tooltip: 'Why this?',
                onPressed: onWhy,
                icon: const Icon(
                  LucideIcons.info,
                  size: 16,
                  color: LearnyColors.slateMedium,
                ),
              ),
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: LearnyColors.slateMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.spaceLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: tokens.radiusXl,
          border: Border.all(color: LearnyColors.sunshine, width: 2),
          boxShadow: tokens.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: LearnyColors.sunshineLight,
                      borderRadius: tokens.radiusLg,
                    ),
                    child: Icon(icon, color: LearnyColors.sunshine, size: 24),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LearnyColors.neutralLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: LearnyColors.neutralLight,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.sessionsCompleted});

  final int sessionsCompleted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = (sessionsCompleted / 7).clamp(0.0, 1.0);

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
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: LearnyColors.neutralMedium,
            ),
          ),
          SizedBox(height: tokens.spaceSm + 4),
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: LearnyColors.neutralSoft,
              borderRadius: tokens.radiusFull,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: tokens.gradientAccent,
                  borderRadius: tokens.radiusFull,
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spaceSm + 4),
          Text(
            'You\'ve completed $sessionsCompleted learning sessions. Great work!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: LearnyColors.neutralLight),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.dueCount, required this.onTap});

  final int dueCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd + 4),
        decoration: BoxDecoration(
          color: LearnyColors.sunshineLight,
          borderRadius: tokens.radiusXl,
          border: Border.all(
            color: LearnyColors.sunshine.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: LearnyColors.sunshine.withValues(alpha: 0.2),
                borderRadius: tokens.radiusMd,
              ),
              child: const Icon(
                LucideIcons.refreshCw,
                color: LearnyColors.sunshine,
                size: 22,
              ),
            ),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dueCount concept${dueCount == 1 ? '' : 's'} to review',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Review now to keep learning!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: LearnyColors.neutralMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: LearnyColors.sunshine,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: tokens.radiusXl,
          boxShadow: tokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: tokens.radiusMd,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: tokens.spaceSm + 4),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LearnyColors.neutralDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackMasterySection extends StatelessWidget {
  const _PackMasterySection({required this.packs, required this.onTapPack});

  final List<LearningPack> packs;
  final void Function(LearningPack pack) onTapPack;

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
          Text(
            'Pack Mastery',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LearnyColors.neutralDark,
            ),
          ),
          const SizedBox(height: 10),
          ...packs.map(
            (pack) => _PackMasteryRow(pack: pack, onTap: () => onTapPack(pack)),
          ),
        ],
      ),
    );
  }
}

class _PackMasteryRow extends StatelessWidget {
  const _PackMasteryRow({required this.pack, required this.onTap});

  final LearningPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = pack.progress.clamp(0.0, 1.0);

    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: tokens.spaceSm + 2),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: pack.color.withValues(alpha: 0.15),
              child: Icon(pack.icon, size: 16, color: pack.color),
            ),
            SizedBox(width: tokens.spaceSm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: LearnyColors.neutralSoft,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 0.8
                            ? LearnyColors.mintPrimary
                            : progress >= 0.5
                            ? LearnyColors.skyPrimary
                            : LearnyColors.sunshine,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: LearnyColors.neutralMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
