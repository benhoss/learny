import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nicknameController = TextEditingController(text: 'Alex');
  String _avatar = 'fox';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final state = AppStateScope.of(context);
    await state.saveOnboardingStep(
      step: 'first_challenge',
      checkpoint: {
        'nickname': _nicknameController.text.trim(),
        'avatar': _avatar,
      },
      completedStep: 'child_avatar',
    );
    final created = await state.createChildForOnboarding(
      name: _nicknameController.text.trim().isEmpty
          ? 'Learner'
          : _nicknameController.text.trim(),
      gradeLevel: state.onboardingCheckpoints['grade']?.toString() ?? '6th',
      preferredLanguage:
          state.onboardingCheckpoints['language']?.toString() ?? 'en',
      role: 'child',
    );

    if (!mounted) return;
    if (created == null) {
      setState(() {
        _busy = false;
        _error = 'Could not create your learner profile. Please try again.';
      });
      return;
    }

    setState(() => _busy = false);
    Navigator.pushReplacementNamed(context, AppRoutes.consent);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: LearnyGradients.hero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Row(
              children: [
                Text(
                  'Choose nickname + avatar',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.welcome,
                  ),
                  child: const Text('Switch role'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                hintText: 'How should we call you?',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AvatarOption(
                  selected: _avatar == 'fox',
                  onTap: () => setState(() => _avatar = 'fox'),
                  image: AppImages.foxMascot,
                  label: 'Fox',
                ),
                _AvatarOption(
                  selected: _avatar == 'buddy',
                  onTap: () => setState(() => _avatar = 'buddy'),
                  image: AppImages.foxStudying,
                  label: 'Buddy',
                ),
                _AvatarOption(
                  selected: _avatar == 'robot',
                  onTap: () => setState(() => _avatar = 'robot'),
                  icon: Icons.smart_toy_rounded,
                  label: 'Robot',
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : _continue,
              child: const Text('Start first challenge'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.selected,
    required this.onTap,
    required this.label,
    this.image,
    this.icon,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final String? image;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? LearnyColors.coral : LearnyColors.slateLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: LearnyColors.peach,
              backgroundImage: image != null ? AssetImage(image!) : null,
              child: image == null && icon != null
                  ? Icon(icon, color: LearnyColors.coral)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
