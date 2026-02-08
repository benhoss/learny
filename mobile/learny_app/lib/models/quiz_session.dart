import 'quiz_question.dart';

class QuizSession {
  QuizSession({
    required this.packId,
    required this.questions,
    this.backendSessionId,
    this.questionIndices = const [],
    this.requestedQuestionCount,
  });

  final String packId;
  final List<QuizQuestion> questions;
  final String? backendSessionId;
  final List<int> questionIndices;
  final int? requestedQuestionCount;
  int currentIndex = 0;
  int correctCount = 0;
  List<int> incorrectIndices = [];
  List<Map<String, dynamic>> results = [];

  bool get isComplete => currentIndex >= questions.length;

  QuizQuestion? get currentQuestion {
    if (currentIndex >= questions.length) {
      return null;
    }
    return questions[currentIndex];
  }
}
