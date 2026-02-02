import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final session = state.quizSession;
    final total = session?.questions.length ?? 0;
    final correct = session?.correctCount ?? 0;
    final isPackSession = state.inPackSession;
    return PlaceholderScreen(
      title: 'Great Job!',
      subtitle: 'You earned ${state.xpToday} XP today and kept your streak.',
      gradient: LearnyGradients.hero,
      body: Column(
        children: [
          const Icon(Icons.celebration_rounded, size: 80, color: LearnyColors.coral),
          const SizedBox(height: 12),
          Text('Accuracy: $correct/$total'),
          const SizedBox(height: 6),
          Text('Total XP: ${state.totalXp}'),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          if (isPackSession) {
            state.completePackSession();
            state.resetQuiz();
            state.endPackSession();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } else {
            state.resetQuiz();
            Navigator.pushNamed(context, AppRoutes.matching);
          }
        },
        child: Text(isPackSession ? 'Finish Session' : 'Next Game'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () {
          state.resetQuiz();
          if (isPackSession) {
            state.completePackSession();
            state.endPackSession();
            Navigator.pushNamed(context, AppRoutes.progressOverview);
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          }
        },
        child: Text(isPackSession ? 'See Progress' : 'Back to Home'),
      ),
    );
  }
}
