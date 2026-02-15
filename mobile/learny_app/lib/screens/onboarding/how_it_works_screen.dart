import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../home/home_shell.dart';
import '../shared/placeholder_screen.dart';

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

  Future<void> _continueWithDemoQuiz() async {
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

  Future<void> _startScanNow() async {
    final state = AppStateScope.of(context);
    await state.startScanFirstOnboarding();
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.upload);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = AppStateScope.of(context);
    final canPop = Navigator.of(context).canPop();
    
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await state.resetOnboarding();
        if (context.mounted) {
          if (canPop) {
            Navigator.of(context).pop();
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.welcome);
          }
        }
      },
      child: PlaceholderScreen(
        title: l10n.howItWorksTitle,
        subtitle: l10n.howItWorksSubtitle,
        gradient: LearnyGradients.trust,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            await state.resetOnboarding();
            if (!context.mounted) return;
            if (canPop) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.welcome);
            }
          },
        ),
        body: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _ageBracket,
            decoration: InputDecoration(labelText: l10n.howItWorksAgeBracketLabel),
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
            decoration: InputDecoration(labelText: l10n.howItWorksGradeLabel),
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
            decoration: InputDecoration(labelText: l10n.howItWorksLanguageLabel),
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
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const HomeShell(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                  (route) => false,
                );
              },
              child: Text(l10n.howItWorksSkipToHome),
            ),
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: _startScanNow,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(l10n.howItWorksScanNow),
      ),
      secondaryAction: OutlinedButton(
        onPressed: _continueWithDemoQuiz,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(l10n.howItWorksTryDemoQuiz),
      ),
    ));
  }
}
