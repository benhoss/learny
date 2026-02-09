import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'gradient_scaffold.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.body,
    this.primaryAction,
    this.secondaryAction,
    this.gradient,
  });

  final String title;
  final String subtitle;
  final Widget? body;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: gradient,
      appBar: AppBar(
        title: Text(L10n.of(context).appTitle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
            const SizedBox(height: 24),
            if (body != null) body!,
            const SizedBox(height: 24),
            if (primaryAction != null) primaryAction!,
            if (secondaryAction != null) ...[
              const SizedBox(height: 12),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
