class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.title,
    required this.subject,
    this.language,
    required this.createdAt,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final String subject;
  final String? language;
  final DateTime createdAt;
  final String statusLabel;

  DocumentItem copyWith({
    String? id,
    String? title,
    String? subject,
    String? language,
    DateTime? createdAt,
    String? statusLabel,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }
}
