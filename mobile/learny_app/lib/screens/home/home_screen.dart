import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final l = L10n.of(context);
    final profile = state.profile;
    final tokens = context.tokens;
    final recommendations = state.homeRecommendations.take(3).toList();
    final isGuest = !state.onboardingComplete;

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
                        l.homeGreeting,
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
                GestureDetector(
                  onTap: state.children.length > 1
                      ? () => _showChildSwitcher(context)
                      : null,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: LearnyColors.skyPrimary,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name.characters.first.toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: tokens.spaceMd),

            // Stats Bar
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding: EdgeInsets.all(tokens.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: tokens.radiusLg,
                  boxShadow: tokens.cardShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: LucideIcons.flame,
                      color: LearnyColors.coral,
                      value: '${state.streakDays}',
                      label: 'Day Streak',
                    ),
                    Container(width: 1, height: 24, color: LearnyColors.neutralSoft),
                    _StatItem(
                      icon: LucideIcons.zap,
                      color: LearnyColors.sunshine,
                      value: '${state.xpToday}',
                      label: 'XP Today',
                    ),
                    Container(width: 1, height: 24, color: LearnyColors.neutralSoft),
                    _StatItem(
                      icon: LucideIcons.target,
                      color: LearnyColors.mintPrimary,
                      value: '${state.mastery.length}',
                      label: 'Topics',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Guest Banner
            if (isGuest) ...[
              FadeInSlide(
                delay: const Duration(milliseconds: 150),
                child: _GuestBanner(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.createProfile),
                ),
              ),
              SizedBox(height: tokens.spaceLg),
            ],

            // Primary Action: Scan New Document
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: PressableScale(
                onTap: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
                child: Container(
                  height: 160,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(LucideIcons.scanLine, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.homeStartLearningTitle,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l.homeStartLearningSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Decorative icon
                      Transform.rotate(
                        angle: -0.1,
                        child: Icon(
                          LucideIcons.fileText,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: tokens.spaceMd),

            // Quick Actions Row
            FadeInSlide(
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: LucideIcons.zap,
                      title: 'Quick Review',
                      color: LearnyColors.sunshine,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.revisionSetup),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: _QuickActionCard(
                      icon: LucideIcons.library,
                      title: 'Library',
                      color: LearnyColors.lavender,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.library),
                    ),
                  ),
                ],
              ),
            ),

            if (state.reviewDueCount > 0) ...[
              SizedBox(height: tokens.spaceLg),
              FadeInSlide(
                delay: const Duration(milliseconds: 350),
                child: _ReviewBanner(
                  count: state.reviewDueCount,
                  onTap: () async {
                    final route = await state.startReviewFromDueConcepts();
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, route ?? AppRoutes.revisionSetup);
                  },
                ),
              ),
            ],

            SizedBox(height: tokens.spaceLg),

            // Recommendations / Continue Learning
            FadeInSlide(
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.homeSmartNextSteps,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LearnyColors.neutralDark,
                    ),
                  ),
                  SizedBox(height: tokens.spaceSm),
                  if (recommendations.isEmpty)
                    _EmptyStateCard(message: l.homeNoRecommendations)
                  else
                    ...recommendations.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RecommendationCard(
                          item: item,
                          onTap: () async {
                            final route = await state.runRecommendationAction(item);
                            if (!context.mounted) return;
                            Navigator.pushNamed(context, route);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            SizedBox(height: tokens.spaceLg),
          ],
        ),
      ),
    );
  }

  void _showChildSwitcher(BuildContext context) {
    // ... existing implementation ...
    final state = AppStateScope.of(context);
    final l = L10n.of(context);
    final tokens = context.tokens;

    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.switchProfile,
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: LearnyColors.neutralDark,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              l.switchProfileHint,
              style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                color: LearnyColors.neutralMedium,
              ),
            ),
            SizedBox(height: tokens.spaceMd),
            ...state.children.map(
              (child) {
                final isSelected = child.id == state.backendChildId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? LearnyColors.skyPrimary
                        : LearnyColors.neutralSoft,
                    child: Text(
                      child.name.characters.first.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : LearnyColors.neutralDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(child.name),
                  subtitle: Text(child.gradeLabel),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: LearnyColors.skyPrimary)
                      : null,
                  onTap: isSelected
                      ? null
                      : () {
                          Navigator.of(sheetContext).pop();
                          state.selectChild(child.id);
                        },
                );
              },
            ),
            SizedBox(height: tokens.spaceMd),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: LearnyColors.neutralDark,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: LearnyColors.neutralMedium,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: LearnyColors.neutralDark.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: LearnyColors.neutralDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  const _GuestBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: LearnyColors.lavender.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: LearnyColors.lavender.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.userPlus, color: LearnyColors.neutralDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Save your progress',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Create a free profile',
                    style: TextStyle(fontSize: 12, color: LearnyColors.neutralMedium),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LearnyColors.sunshine,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: LearnyColors.sunshine.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.clock, color: LearnyColors.neutralDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Time to review $count concepts!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: LearnyColors.neutralDark,
                ),
              ),
            ),
            const Icon(LucideIcons.arrowRight, color: LearnyColors.neutralDark),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: LearnyColors.neutralDark.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LearnyColors.mintLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.sparkles, color: LearnyColors.mintPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']?.toString() ?? 'Recommendation',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle']?.toString() ?? 'Based on your activity',
                    style: const TextStyle(
                      fontSize: 12,
                      color: LearnyColors.neutralMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.playCircle, color: LearnyColors.skyPrimary),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: const TextStyle(color: LearnyColors.neutralMedium),
        textAlign: TextAlign.center,
      ),
    );
  }
}
