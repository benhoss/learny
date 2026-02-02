class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.hint,
    this.explanation,
    this.correctIndices,
    this.answerText,
    this.acceptedAnswers,
    this.orderedSequence,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? hint;
  final String? explanation;
  final List<int>? correctIndices;
  final String? answerText;
  final List<String>? acceptedAnswers;
  final List<String>? orderedSequence;

  bool get isMultiSelect => (correctIndices?.length ?? 0) > 1;
  bool get isTextInput => answerText != null;
  bool get isOrdering => orderedSequence != null && orderedSequence!.isNotEmpty;
}
