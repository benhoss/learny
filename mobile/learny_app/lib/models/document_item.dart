class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.createdAt,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime createdAt;
  final String statusLabel;

  DocumentItem copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? createdAt,
    String? statusLabel,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }
}
