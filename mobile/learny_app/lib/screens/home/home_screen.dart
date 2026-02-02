import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile = state.profile;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: LearnyColors.peach,
              backgroundImage: AssetImage(profile.avatarAsset),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${profile.name}!',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${state.streakDays}-day streak • ${state.xpToday} XP today',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: LearnyColors.slateMedium),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: LearnyColors.peach.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(AppImages.foxStudying),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learny Tip',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Keep answers short — the app turns them into games.',
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
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Quest',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Finish 1 quiz and review 10 flashcards.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: LearnyColors.slateMedium),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  state.startQuiz();
                  Navigator.pushNamed(context, AppRoutes.quiz);
                },
                child: const Text('Start Quiz'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickTile(
                title: 'Snap Homework',
                icon: Icons.camera_alt_rounded,
                color: LearnyColors.coral,
                onTap: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickTile(
                title: 'Learning Packs',
                icon: Icons.auto_stories_rounded,
                color: LearnyColors.teal,
                onTap: () => Navigator.pushNamed(context, AppRoutes.packsList),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickTile(
                title: 'Revision Express',
                icon: Icons.flash_on_rounded,
                color: LearnyColors.purple,
                onTap: () => Navigator.pushNamed(context, AppRoutes.revisionSetup),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickTile(
                title: 'Achievements',
                icon: Icons.emoji_events_rounded,
                color: LearnyColors.coralLight,
                onTap: () => Navigator.pushNamed(context, AppRoutes.achievements),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Explore',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _NavChip(label: 'Parent Dashboard', route: AppRoutes.parentDashboard),
            _NavChip(label: 'Progress Overview', route: AppRoutes.progressOverview),
            _NavChip(label: 'Safety & Privacy', route: AppRoutes.safetyPrivacy),
            _NavChip(label: 'Support', route: AppRoutes.contactSupport),
            _NavChip(label: 'Subscription', route: AppRoutes.subscription),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System States',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.emptyState),
                    child: const Text('Empty'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.errorState),
                    child: const Text('Error'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.offline),
                    child: const Text('Offline'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => Navigator.pushNamed(context, route),
      backgroundColor: LearnyColors.sky,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
