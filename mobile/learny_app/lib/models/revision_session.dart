import 'revision_prompt.dart';

class RevisionSession {
  RevisionSession({
    this.backendSessionId,
    required this.prompts,
    required this.subjectLabel,
    required this.durationMinutes,
  });

  final String? backendSessionId;
  final List<RevisionPrompt> prompts;
  final String subjectLabel;
  final int durationMinutes;

  int currentIndex = 0;
  int correctCount = 0;

  bool get isComplete => currentIndex >= prompts.length;

  RevisionPrompt? get currentPrompt {
    if (currentIndex >= prompts.length) {
      return null;
    }
    return prompts[currentIndex];
  }
}
