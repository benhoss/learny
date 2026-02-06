import 'quiz_question.dart';

class QuizSession {
  QuizSession({
    required this.packId,
    required this.questions,
  });

  final String packId;
  final List<QuizQuestion> questions;
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
