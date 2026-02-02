import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final isReady = state.quizSession != null && !state.isGeneratingQuiz;
    return PlaceholderScreen(
      title: 'Processing Document',
      subtitle: state.generationStatus,
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          const SizedBox(height: 8),
          if (state.generationError == null) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('OCR • Concepts • Pack Generation'),
          ] else ...[
            const Icon(Icons.error_outline_rounded, size: 48, color: LearnyColors.coral),
            const SizedBox(height: 12),
            Text(
              state.generationError ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: isReady
            ? () => Navigator.pushNamed(context, AppRoutes.quiz)
            : null,
        child: const Text('Start Quiz'),
      ),
      secondaryAction: state.generationError == null
          ? null
          : OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
    );
  }
}
