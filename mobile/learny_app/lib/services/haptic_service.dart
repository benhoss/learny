import 'package:flutter/services.dart';

/// Semantic haptic feedback patterns for the Learny app.
/// Provides consistent tactile feedback across all interactions.
class HapticService {
  HapticService._();

  /// Light tap for button presses and selections
  static void tap() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for card flips and transitions
  static void flip() {
    HapticFeedback.mediumImpact();
  }

  /// Success pattern for correct answers and matches
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error pattern for incorrect answers
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for choosing options
  static void select() {
    HapticFeedback.selectionClick();
  }

  /// Celebration pattern for achievements and level ups
  static Future<void> celebrate() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }

  /// Match found in matching game
  static void matchFound() {
    HapticFeedback.mediumImpact();
  }

  /// No match in matching game
  static void noMatch() {
    HapticFeedback.lightImpact();
  }

  /// Warning or attention needed
  static void warning() {
    HapticFeedback.heavyImpact();
  }
}
