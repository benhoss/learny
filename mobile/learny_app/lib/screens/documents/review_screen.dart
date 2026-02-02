import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';
import '../shared/placeholder_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _subjectController = TextEditingController();
  final _languageController = TextEditingController();
  final _goalController = TextEditingController();
  final _contextController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _languageController.dispose();
    _goalController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return PlaceholderScreen(
      title: 'Review Capture',
      subtitle: 'Crop, rotate, or retake if needed.',
      gradient: LearnyGradients.trust,
      body: Column(
        children: [
          state.pendingImageBytes == null
              ? Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo, size: 80, color: LearnyColors.slateLight),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.memory(
                    state.pendingImageBytes!,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
          _ReviewContextFields(
            subjectController: _subjectController,
            languageController: _languageController,
            goalController: _goalController,
            contextController: _contextController,
          ),
        ],
      ),
      primaryAction: ElevatedButton(
        onPressed: () {
          state.setPendingContext(
            subject: _subjectController.text.trim(),
            language: _languageController.text.trim(),
            learningGoal: _goalController.text.trim(),
            contextText: _contextController.text.trim(),
          );
          state.generateQuizFromPendingImage();
          Navigator.pushNamed(context, AppRoutes.processing);
        },
        child: const Text('Looks Good'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cameraCapture),
        child: const Text('Retake'),
      ),
    );
  }
}

class _ReviewContextFields extends StatelessWidget {
  const _ReviewContextFields({
    required this.subjectController,
    required this.languageController,
    required this.goalController,
    required this.contextController,
  });

  final TextEditingController subjectController;
  final TextEditingController languageController;
  final TextEditingController goalController;
  final TextEditingController contextController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: subjectController,
          decoration: const InputDecoration(
            labelText: 'Subject (optional)',
            hintText: 'e.g. French verbs',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: languageController,
          decoration: const InputDecoration(
            labelText: 'Language (optional)',
            hintText: 'e.g. French',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: goalController,
          decoration: const InputDecoration(
            labelText: 'Learning goal (optional)',
            hintText: 'e.g. Present tense conjugation',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: contextController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Extra context (optional)',
            hintText: 'Short notes to guide quiz generation',
          ),
        ),
      ],
    );
  }
}
