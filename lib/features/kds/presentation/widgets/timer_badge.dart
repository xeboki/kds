import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/kds_theme.dart';
import '../../domain/line_meanings.dart';

/// Live timer badge, measured against when the order is **due**.
///
/// Past due it counts up and the colour cycles green → amber → red →
/// deep-red on the configurable thresholds (default 8 / 15 / 25 min).
/// Still ahead of its time — a pre-order or catering order — it counts
/// **down** in a neutral blue and never escalates, because an order nobody
/// expects yet is not late.
class TimerBadge extends StatefulWidget {
  const TimerBadge({
    super.key,
    required this.dueAt,
    this.urgentMins = 8,
    this.veryUrgentMins = 15,
    this.criticalMins = 25,
  });

  final DateTime dueAt;
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

  /// Counting down to a time that has not come yet.
  bool _ahead = false;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_update);
    });
  }

  void _update() {
    final diff = DateTime.now().difference(widget.dueAt);
    _ahead = diff.isNegative;
    final abs = diff.abs();
    _minutes = abs.inMinutes;
    _seconds = abs.inSeconds % 60;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Takes a context because the ramp is the till's, and the till's
  /// semantic colours differ between light and dark so they stay legible on
  /// either ground.
  Color _colorOf(BuildContext context) {
    final kitchen = context.kitchen;
    // An order still ahead of its time never escalates. It is on the board so
    // the kitchen can plan around it, not so it can be shouted about.
    if (_ahead) return context.appColors.info;
    if (_minutes >= widget.criticalMins) return kitchen.ageUrgent;
    if (_minutes >= widget.veryUrgentMins) return kitchen.ageRed;
    if (_minutes >= widget.urgentMins) return kitchen.ageAmber;
    return kitchen.ageOk;
  }

  @override
  Widget build(BuildContext context) {
    // Hours appear once there are any, so a pre-order reads "in 4:20:00"
    // rather than a 260-minute count a cook has to divide.
    final hours = _minutes ~/ 60;
    final mm = (_minutes % 60).toString().padLeft(2, '0');
    final ss = _seconds.toString().padLeft(2, '0');
    final clock = hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
    final label = _ahead ? 'in $clock' : clock;
    return Tooltip(
      // What the colour means, with this screen's own rungs in it — a cook
      // with a mouse should not have to open the legend to find out why a
      // ticket has gone red.
      message: timerMeaning(
        minutes: _minutes,
        countingDown: _ahead,
        urgentMins: widget.urgentMins,
        veryUrgentMins: widget.veryUrgentMins,
      ),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _colorOf(context).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _colorOf(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_ahead ? Icons.schedule : Icons.timer_outlined,
              size: 12, color: _colorOf(context)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _colorOf(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
