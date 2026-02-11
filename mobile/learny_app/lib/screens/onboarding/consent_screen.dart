import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final List<_Question> _questions = const [
    _Question(prompt: '2 + 3 = ?', options: ['4', '5', '6'], answer: '5'),
    _Question(
      prompt: 'Water freezes at?',
      options: ['0C', '50C', '100C'],
      answer: '0C',
    ),
    _Question(
      prompt: 'Language of this app?',
      options: ['Code', 'English', 'Math'],
      answer: 'English',
    ),
  ];

  int _index = 0;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = AppStateScope.of(context);
      state.trackOnboardingEvent(
        role: 'child',
        eventName: 'first_learning_started',
        step: 'first_challenge',
      );
    });
  }

  Future<void> _answer(String option) async {
    final question = _questions[_index];
    if (option == question.answer) {
      _correct += 1;
    }

    if (_index == _questions.length - 1) {
      final state = AppStateScope.of(context);
      await state.trackOnboardingEvent(
        role: 'child',
        eventName: 'first_learning_completed',
        step: 'first_challenge',
        metadata: {'score': _correct, 'total': _questions.length},
      );
      await state.saveOnboardingStep(
        step: 'parent_link_prompt',
        completedStep: 'first_challenge',
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.plan);
      return;
    }

    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    final progress = (_index + 1) / _questions.length;

    return GradientScaffold(
      gradient: LearnyGradients.trust,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'First challenge',
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
            const Text('3 quick questions for your first win.'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 24),
            Text(
              question.prompt,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...question.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _answer(option),
                    child: Text(option),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Question {
  const _Question({
    required this.prompt,
    required this.options,
    required this.answer,
  });

  final String prompt;
  final List<String> options;
  final String answer;
}
