class RevisionPrompt {
  const RevisionPrompt({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.selectionReason,
    this.confidence,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? selectionReason;
  final double? confidence;
}
