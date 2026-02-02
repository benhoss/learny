class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final bool isRead;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timeLabel,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      isRead: isRead ?? this.isRead,
    );
  }
}
