import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  static const _ageBrackets = ['10-11', '12-13', '14+'];
  static const _grades = ['5th', '6th', '7th', '8th'];
  static const _languages = ['en', 'fr', 'nl'];

  String _ageBracket = _ageBrackets.first;
  String _grade = _grades[1];
  String _language = _languages.first;

  Future<void> _continue() async {
    final state = AppStateScope.of(context);
    await state.saveOnboardingStep(
      step: 'child_avatar',
      checkpoint: {
        'age_bracket': _ageBracket,
        'grade': _grade,
        'language': _language,
        'market': 'US',
      },
      completedStep: 'child_profile',
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.createProfile);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: LearnyGradients.trust,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Row(
              children: [
                Text(
                  'Quick profile',
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
            const SizedBox(height: 8),
            const Text('Three quick inputs, then your first challenge.'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _ageBracket,
              decoration: const InputDecoration(labelText: 'Age bracket'),
              items: _ageBrackets
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _ageBracket = value ?? _ageBracket),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _grade,
              decoration: const InputDecoration(labelText: 'Grade'),
              items: _grades
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _grade = value ?? _grade),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: _languages
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _language = value ?? _language),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _continue, child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}
