import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_tokens.dart';

class TimerBadge extends StatefulWidget {
  const TimerBadge({
    super.key,
    required this.seconds,
  });

  final int seconds;

  @override
  State<TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<TimerBadge> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }
      if (_remaining <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  @override
  void didUpdateWidget(covariant TimerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seconds != oldWidget.seconds) {
      _remaining = widget.seconds;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isUrgent = _remaining <= 5;
    final isWarning = _remaining <= 15;
    final color = isUrgent
        ? LearnyColors.coral
        : isWarning
            ? LearnyColors.sunshine
            : LearnyColors.skyPrimary;
    return AnimatedContainer(
      duration: tokens.microDuration,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: tokens.radiusFull,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.timer,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '${_remaining}s',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
