class WeeklySummary {
  const WeeklySummary({
    required this.minutesSpent,
    required this.newBadges,
    required this.sessionsCompleted,
    required this.topSubject,
  });

  final int minutesSpent;
  final int newBadges;
  final int sessionsCompleted;
  final String topSubject;
}
