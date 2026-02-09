import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  static const _supportedLanguages = [
    ('en', 'English'),
    ('fr', 'Français'),
    ('nl', 'Nederlands'),
  ];

  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return GradientScaffold(
      gradient: LearnyGradients.hero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              l.createProfileTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l.createProfileSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: LearnyColors.slateMedium),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: l.createProfileNameLabel,
                hintText: l.createProfileNameHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.createProfileLanguageLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _supportedLanguages
                  .map((lang) => DropdownMenuItem(
                        value: lang.$1,
                        child: Text(lang.$2),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              l.createProfileAvatarLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AvatarChip(image: AppImages.foxMascot, label: l.createProfileAvatarFox),
                _AvatarChip(
                  image: AppImages.foxStudying,
                  label: l.createProfileAvatarFoxBuddy,
                ),
                _AvatarChip(icon: Icons.bug_report_rounded, label: l.createProfileAvatarRobot),
                _AvatarChip(icon: Icons.emoji_nature_rounded, label: l.createProfileAvatarOwl),
                _AvatarChip(
                  icon: Icons.sports_soccer_rounded,
                  label: l.createProfileAvatarPenguin,
                ),
                _AvatarChip(icon: Icons.park_rounded, label: l.createProfileAvatarDino),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.consent),
              child: Text(l.createProfileContinue),
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
