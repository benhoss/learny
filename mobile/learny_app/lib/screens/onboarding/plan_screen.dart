import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: LearnyGradients.hero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'Choose Your Plan',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Start free. Upgrade anytime.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
            const SizedBox(height: 20),
            _PlanCard(
              title: 'Free',
              subtitle: '3 packs per month',
              price: '\$0',
              highlight: false,
              onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
            ),
            _PlanCard(
              title: 'Pro',
              subtitle: 'Unlimited packs + games',
              price: '\$9.99',
              highlight: true,
              onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
            ),
            _PlanCard(
              title: 'Family',
              subtitle: 'Up to 4 child profiles',
              price: '\$14.99',
              highlight: false,
              onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              child: const Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.highlight,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: highlight ? LearnyColors.slateDark : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: highlight ? LearnyColors.coral : LearnyColors.peach,
          child: Icon(
            highlight ? Icons.star_rounded : Icons.favorite_rounded,
            color: highlight ? Colors.white : LearnyColors.coral,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: highlight ? Colors.white : LearnyColors.slateDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: highlight ? Colors.white70 : LearnyColors.slateMedium,
          ),
        ),
        trailing: Text(
          price,
          style: TextStyle(
            color: highlight ? Colors.white : LearnyColors.slateDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
