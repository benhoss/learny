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
    this.conceptsMastered = 0,
    this.conceptsTotal = 0,
    this.conceptKeys = const [],
  });

  final String id;
  final String title;
  final String subject;
  final int itemCount;
  final int minutes;
  final IconData icon;
  final Color color;
  final double progress;
  final int conceptsMastered;
  final int conceptsTotal;
  final List<String> conceptKeys;

  LearningPack copyWith({
    String? id,
    String? title,
    String? subject,
    int? itemCount,
    int? minutes,
    IconData? icon,
    Color? color,
    double? progress,
    int? conceptsMastered,
    int? conceptsTotal,
    List<String>? conceptKeys,
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
      conceptsMastered: conceptsMastered ?? this.conceptsMastered,
      conceptsTotal: conceptsTotal ?? this.conceptsTotal,
      conceptKeys: conceptKeys ?? this.conceptKeys,
    );
  }
}
