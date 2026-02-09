import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return GradientScaffold(
      gradient: LearnyGradients.trust,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              l.onboardingConsentTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l.onboardingConsentSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
            const SizedBox(height: 24),
            _ConsentItem(
              icon: Icons.shield_rounded,
              title: l.onboardingConsentCoppaTitle,
              subtitle: l.onboardingConsentCoppaSubtitle,
            ),
            _ConsentItem(
              icon: Icons.lock_rounded,
              title: l.onboardingConsentNoDataSellingTitle,
              subtitle: l.onboardingConsentNoDataSellingSubtitle,
            ),
            _ConsentItem(
              icon: Icons.verified_rounded,
              title: l.onboardingConsentEducatorTitle,
              subtitle: l.onboardingConsentEducatorSubtitle,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
              child: Text(l.onboardingConsentAgreeButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentItem extends StatelessWidget {
  const _ConsentItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: LearnyColors.sky,
          child: Icon(icon, color: LearnyColors.coral),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
