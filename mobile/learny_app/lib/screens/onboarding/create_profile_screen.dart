import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: LearnyGradients.hero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'You\'re Ready!',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s learn together.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Profile name',
                hintText: 'Your name',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose your avatar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _AvatarChip(image: AppImages.foxMascot, label: 'Fox'),
                _AvatarChip(image: AppImages.foxStudying, label: 'Fox Buddy'),
                _AvatarChip(icon: Icons.bug_report_rounded, label: 'Robot'),
                _AvatarChip(icon: Icons.emoji_nature_rounded, label: 'Owl'),
                _AvatarChip(icon: Icons.sports_soccer_rounded, label: 'Penguin'),
                _AvatarChip(icon: Icons.park_rounded, label: 'Dino'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.consent),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({this.icon, this.image, required this.label});

  final IconData? icon;
  final String? image;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: LearnyColors.peach,
        backgroundImage: image != null ? AssetImage(image!) : null,
        child: image == null && icon != null
            ? Icon(icon, color: LearnyColors.coral)
            : null,
      ),
      label: Text(label),
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
