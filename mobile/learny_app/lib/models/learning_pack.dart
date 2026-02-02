import 'package:flutter/material.dart';

class LearningPack {
  const LearningPack({
    required this.id,
    required this.title,
    required this.subject,
    required this.itemCount,
    required this.minutes,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String id;
  final String title;
  final String subject;
  final int itemCount;
  final int minutes;
  final IconData icon;
  final Color color;
  final double progress;

  LearningPack copyWith({
    String? id,
    String? title,
    String? subject,
    int? itemCount,
    int? minutes,
    IconData? icon,
    Color? color,
    double? progress,
  }) {
    return LearningPack(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      itemCount: itemCount ?? this.itemCount,
      minutes: minutes ?? this.minutes,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      progress: progress ?? this.progress,
    );
  }
}
