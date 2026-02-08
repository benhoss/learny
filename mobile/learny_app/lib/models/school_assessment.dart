class SchoolAssessment {
  const SchoolAssessment({
    required this.id,
    required this.subject,
    required this.assessmentType,
    required this.score,
    required this.maxScore,
    required this.assessedAt,
    this.grade,
    this.teacherNote,
    this.source = 'manual',
    this.scorePercent,
  });

  final String id;
  final String subject;
  final String assessmentType;
  final double score;
  final double maxScore;
  final DateTime assessedAt;
  final String? grade;
  final String? teacherNote;
  final String source;
  final double? scorePercent;

  factory SchoolAssessment.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    return SchoolAssessment(
      id: id,
      subject: json['subject']?.toString() ?? 'Unknown',
      assessmentType: json['assessment_type']?.toString() ?? 'unknown',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
      assessedAt:
          DateTime.tryParse(json['assessed_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      grade: json['grade']?.toString(),
      teacherNote: json['teacher_note']?.toString(),
      source: json['source']?.toString() ?? 'manual',
      scorePercent: (json['score_percent'] as num?)?.toDouble(),
    );
  }
}
