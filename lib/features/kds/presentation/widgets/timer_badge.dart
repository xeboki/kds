import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Live age timer badge. Colour cycles green → amber → red → deep-red
/// based on the configurable thresholds (default 8 / 15 / 25 min).
class TimerBadge extends StatefulWidget {
  const TimerBadge({
    super.key,
    required this.orderTime,
    this.urgentMins = 8,
    this.veryUrgentMins = 15,
    this.criticalMins = 25,
  });

  final DateTime orderTime;
  final int urgentMins;
  final int veryUrgentMins;
  final int criticalMins;

  @override
  State<TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<TimerBadge> {
  late Timer _timer;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_update);
    });
  }

  void _update() {
    final diff = DateTime.now().difference(widget.orderTime);
    _minutes = diff.inMinutes;
    _seconds = diff.inSeconds % 60;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color get _color {
    if (_minutes >= widget.criticalMins) return KdsTheme.ageUrgent;
    if (_minutes >= widget.veryUrgentMins) return KdsTheme.ageRed;
    if (_minutes >= widget.urgentMins) return KdsTheme.ageAmber;
    return KdsTheme.ageOk;
  }

  @override
  Widget build(BuildContext context) {
    final label =
        '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
