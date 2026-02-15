import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/placeholder_screen.dart';

class GuestLimitScreen extends StatelessWidget {
  const GuestLimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Free session complete',
      subtitle: 'You\'ve completed your free guest session! Create a profile to save your progress and continue learning.',
      gradient: LearnyGradients.trust,
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: LearnyColors.neutralDark.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.lock_clock_rounded,
              size: 48,
              color: LearnyColors.mintPrimary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Why create an account?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _FeatureRow(icon: Icons.save_rounded, text: 'Save your quiz results'),
            const SizedBox(height: 8),
            _FeatureRow(icon: Icons.history_rounded, text: 'Track progress over time'),
            const SizedBox(height: 8),
            _FeatureRow(icon: Icons.devices_rounded, text: 'Sync across devices'),
          ],
        ),
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createProfile);
        },
        child: const Text('Create free profile'),
      ),
      secondaryAction: TextButton(
        onPressed: () {
          // Just exit to home/welcome, but state will block re-entry
          Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        },
        child: const Text('Exit to Welcome Screen'),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: LearnyColors.skyPrimary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
