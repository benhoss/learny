class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.completedAt,
    required this.gameType,
    required this.subject,
    required this.scorePercent,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpEarned,
    required this.cheerMessage,
    this.packId,
    this.packTitle,
    this.documentId,
    this.documentTitle,
    this.progressionDelta,
    this.availableGameTypes = const [],
    this.remainingGameTypes = const [],
  });

  final String id;
  final DateTime completedAt;
  final String gameType;
  final String subject;
  final int scorePercent;
  final int correctAnswers;
  final int totalQuestions;
  final int xpEarned;
  final String cheerMessage;
  final String? packId;
  final String? packTitle;
  final String? documentId;
  final String? documentTitle;
  final int? progressionDelta;
  final List<String> availableGameTypes;
  final List<String> remainingGameTypes;

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final completedAt =
        DateTime.tryParse(json['completed_at']?.toString() ?? '') ??
        DateTime.now();

    return ActivityItem(
      id: json['id']?.toString() ?? '',
      completedAt: completedAt,
      gameType: json['game_type']?.toString() ?? '',
      subject: json['subject']?.toString() ?? 'General',
      scorePercent: (json['score_percent'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correct_answers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      cheerMessage:
          json['cheer_message']?.toString() ??
          'Keep going. Every attempt helps.',
      packId: json['pack_id']?.toString(),
      packTitle: json['pack_title']?.toString(),
      documentId: json['document_id']?.toString(),
      documentTitle: json['document_title']?.toString(),
      progressionDelta: (json['progression_delta'] as num?)?.toInt(),
      availableGameTypes: (json['available_game_types'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      remainingGameTypes: (json['remaining_game_types'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
