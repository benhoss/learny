import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return GradientScaffold(
      gradient: LearnyGradients.trust,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.onboardingHowItWorksTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              l.onboardingHowItWorksSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: LearnyColors.peach.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(AppImages.foxStudying),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l.onboardingFoxBlurb,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: LearnyColors.slateMedium),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _StepCard(
              title: l.onboardingStep1Title,
              subtitle: l.onboardingStep1Subtitle,
              icon: Icons.camera_alt_rounded,
              color: LearnyColors.coral,
            ),
            const SizedBox(height: 16),
            _StepCard(
              title: l.onboardingStep2Title,
              subtitle: l.onboardingStep2Subtitle,
              icon: Icons.auto_awesome_rounded,
              color: LearnyColors.teal,
            ),
            const SizedBox(height: 16),
            _StepCard(
              title: l.onboardingStep3Title,
              subtitle: l.onboardingStep3Subtitle,
              icon: Icons.emoji_events_rounded,
              color: LearnyColors.purple,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.createProfile),
                child: Text(l.onboardingCreateProfileButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: LearnyColors.slateMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
