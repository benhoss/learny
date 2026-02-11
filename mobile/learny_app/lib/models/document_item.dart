class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    this.language,
    this.gradeLevel,
    this.tags = const [],
    this.collections = const [],
    required this.createdAt,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final String subject;
  final String topic;
  final String? language;
  final String? gradeLevel;
  final List<String> tags;
  final List<String> collections;
  final DateTime createdAt;
  final String statusLabel;

  DocumentItem copyWith({
    String? id,
    String? title,
    String? subject,
    String? topic,
    String? language,
    String? gradeLevel,
    List<String>? tags,
    List<String>? collections,
    DateTime? createdAt,
    String? statusLabel,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      language: language ?? this.language,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      tags: tags ?? this.tags,
      collections: collections ?? this.collections,
      createdAt: createdAt ?? this.createdAt,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }
}
