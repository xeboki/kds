/// How the kitchen is doing, right now.
///
/// SPEC-097. Everything here is derived from the two lists the board already
/// watches — there is no new metric and nothing stored — so it cannot
/// disagree with the cards on screen.
///
/// It answers what a head chef asks across a service without counting tickets
/// by eye: how far behind are we, is the board backed up at one status, what
/// is going out, and what is the section buried under. The numbers are scoped
/// to **this screen**, because `kitchenOrdersProvider` already filters to the
/// routing categories it is switched on for: a grill screen reports the
/// grill's backlog, an expo screen reports the pass.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kds_theme.dart';
import '../../domain/kitchen_stats.dart';
import '../../domain/models/kitchen_order.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/kitchen_providers.dart';

Future<void> showAnalyticsPanel(BuildContext context) => showDialog(
      context: context,
      // A kitchen screen is wide and on a wall, and a chef glances at it. As
      // a bottom sheet this was a 620-pixel column down the middle of a
      // 1580-pixel display, with two thirds of the screen given to scrim and
      // the whole picture four scrolls long.
      builder: (_) => const AnalyticsPanel(),
    );

class AnalyticsPanel extends ConsumerWidget {
  const AnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final orders = ref.watch(kitchenOrdersProvider);
    final bumped = ref.watch(bumpedForStatsProvider);
    final session = ref.watch(sessionProvider);

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        // Wide enough to lay the whole picture out side by side, capped so it
        // does not stretch to absurd widths on a very large display.
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Icon(Icons.insights_outlined, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kitchen analytics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        // Said out loud, because the same panel on the grill
                        // and at the pass shows different numbers and nothing
                        // on it used to explain why.
                        Text(
                          session == null
                              ? 'This screen'
                              : session.isExpo
                                  ? 'Everything at the pass'
                                  : 'This screen\u2019s sections only',
                          style: TextStyle(
                              fontSize: 12, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: orders.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Could not read the board \u2014 $e',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.kitchen.ageRed)),
                  ),
                ),
                data: (active) => AnalyticsBody(
                  stats: computeKitchenStats(
                    active: active,
                    bumped: bumped.valueOrNull ?? const [],
                    routingCategoryIds:
                        session?.routingCategoryIds ?? const [],
                    isExpo: session?.isExpo ?? false,
                    urgentMins: session?.urgentThresholdMins ?? 8,
                    veryUrgentMins: session?.veryUrgentThresholdMins ?? 15,
                  ),
                  urgentMins: session?.urgentThresholdMins ?? 8,
                  veryUrgentMins: session?.veryUrgentThresholdMins ?? 15,
                  // A pending read is not an empty hour. Without this the
                  // throughput chart drew a flat zero and then jumped.
                  historyLoaded: bumped.hasValue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dashboard itself, without the dialog around it.
///
/// Public so a widget test can pump it at a given screen size — the layout
/// rules it encodes (what fits, and what a column count does to four
/// sections) are exactly what cannot be checked on the figures alone.
class AnalyticsBody extends StatelessWidget {
  const AnalyticsBody({
    super.key,
    required this.stats,
    required this.urgentMins,
    required this.veryUrgentMins,
    required this.historyLoaded,
  });

  final KitchenStats stats;
  final int urgentMins;
  final int veryUrgentMins;
  final bool historyLoaded;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _Panel(
        title: 'HOW FAR BEHIND',
        subtitle: 'Open tickets, by how long they have waited',
        child: _BandBar(
            stats: stats,
            urgentMins: urgentMins,
            veryUrgentMins: veryUrgentMins),
      ),
      _Panel(
        title: 'WHERE THE WORK IS',
        subtitle: 'Lines by what has been done to them',
        child: _StatusBreakdown(stats: stats),
      ),
      _Panel(
        title: 'GOING OUT',
        subtitle: 'Tickets away, each of the last six ten-minute stretches',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!historyLoaded)
              const _Pending()
            else
              _Throughput(stats: stats),
            const SizedBox(height: 14),
            _ThroughputFigures(
                stats: stats,
                historyLoaded: historyLoaded,
                urgentMins: urgentMins,
                veryUrgentMins: veryUrgentMins),
          ],
        ),
      ),
      _Panel(
        title: 'BURIED UNDER',
        subtitle: 'Dishes still to make, most of them first',
        child: stats.busiest.isEmpty
            ? const _Empty(text: 'Nothing left to make.')
            : _Busiest(stats: stats),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Four sections, so the column count has to divide four: at three
        // columns the dealing gave 2/1/1 and the tallest section ran off the
        // bottom while two columns sat empty. One per column on a kitchen
        // display, two-by-two on a laptop, stacked on anything narrow.
        final columns = constraints.maxWidth >= 1320
            ? 4
            : constraints.maxWidth >= 720
                ? 2
                : 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The verdict and the figures stay full width at the top: they
              // are what a chef reads first and they must not be buried in a
              // column with everything else.
              _Verdict(stats: stats, veryUrgentMins: veryUrgentMins),
              const SizedBox(height: 14),
              _KeyFigures(
                  stats: stats,
                  urgentMins: urgentMins,
                  veryUrgentMins: veryUrgentMins),
              const SizedBox(height: 18),
              _Columns(columns: columns, children: sections),
            ],
          ),
        );
      },
    );
  }
}

/// Lays the sections out in [columns], filling across then down.
class _Columns extends StatelessWidget {
  const _Columns({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final child in children) ...[
            child,
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    // Filled down a column and then across, so the order they are read in
    // matches the order they are written in.
    final perColumn = (children.length + columns - 1) ~/ columns;
    final buckets = [
      for (var c = 0; c < columns; c++)
        children.skip(c * perColumn).take(perColumn).toList(),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final child in buckets[c]) ...[
                  child,
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          if (c < columns - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

/// One bordered section of the dashboard.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: colors.textSecondary)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(fontSize: 11, color: colors.onDisabled)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// The four headline figures.
class _KeyFigures extends StatelessWidget {
  const _KeyFigures({
    required this.stats,
    required this.urgentMins,
    required this.veryUrgentMins,
  });

  final KitchenStats stats;
  final int urgentMins;
  final int veryUrgentMins;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        _Stat(
          label: 'Open tickets',
          value: '${stats.openTickets}',
          footnote: stats.scheduledAhead > 0
              ? '${stats.scheduledAhead} not due yet'
              : null,
          color: colors.primary,
        ),
        const SizedBox(width: 12),
        _Stat(
          label: 'Lines to make',
          value: '${stats.linesToMake}',
          footnote: stats.linesOff > 0 ? '${stats.linesOff} off' : null,
          color: colors.primary,
        ),
        const SizedBox(width: 12),
        _Stat(
          label: 'Longest wait',
          value: '${stats.oldestWaitMins}m',
          color: waitColour(context, stats.oldestWaitMins,
              urgentMins: urgentMins, veryUrgentMins: veryUrgentMins),
        ),
        const SizedBox(width: 12),
        _Stat(
          label: 'Typical wait',
          value: '${stats.medianWaitMins}m',
          // The median, not the mean. One forgotten ticket drags an average
          // up and makes a calm board look like a bad one.
          footnote: 'average ${stats.averageWaitMins}m',
          color: waitColour(context, stats.medianWaitMins,
              urgentMins: urgentMins, veryUrgentMins: veryUrgentMins),
        ),
      ],
    );
  }
}

/// Bumped, recalled and turnaround, under the throughput chart.
class _ThroughputFigures extends StatelessWidget {
  const _ThroughputFigures({
    required this.stats,
    required this.historyLoaded,
    required this.urgentMins,
    required this.veryUrgentMins,
  });

  final KitchenStats stats;

  /// Until the hour has been read these figures are not zero, they are
  /// unknown — and "0 away, last hour" during a busy service is a worse
  /// answer than saying nothing yet.
  final bool historyLoaded;
  final int urgentMins;
  final int veryUrgentMins;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final kitchen = context.kitchen;
    return Row(
      children: [
        _MiniFigure(
          label: 'away, last hour',
          value: historyLoaded ? '${stats.bumpedLastHour}' : '\u2014',
          color: historyLoaded ? kitchen.statusReady : colors.onDisabled,
        ),
        // Deliberately beside the bump count. A recall is a mistake being
        // undone or a plate coming back; the number means nothing alone.
        _MiniFigure(
          label: 'recalled',
          value: historyLoaded ? '${stats.recalledLastHour}' : '\u2014',
          color: !historyLoaded
              ? colors.onDisabled
              : stats.recalledLastHour > 0
                  ? kitchen.ageRed
                  : colors.textSecondary,
        ),
        _MiniFigure(
          label: stats.averageTurnaroundMins == null || !historyLoaded
              ? 'rung to away'
              : 'rung to away, average',
          value: !historyLoaded || stats.averageTurnaroundMins == null
              ? '\u2014'
              : '${stats.averageTurnaroundMins}m',
          color: !historyLoaded || stats.averageTurnaroundMins == null
              ? colors.onDisabled
              : waitColour(context, stats.averageTurnaroundMins!,
                  urgentMins: urgentMins, veryUrgentMins: veryUrgentMins),
        ),
      ],
    );
  }
}

class _MiniFigure extends StatelessWidget {
  const _MiniFigure({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      // Keyed by what it measures, so a test can ask this figure what it
      // says rather than searching the whole panel for a digit.
      key: ValueKey('figure-$label'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              maxLines: 2,
              style: TextStyle(fontSize: 11, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

/// The wait ramp, shared so every figure on the panel colours the same way.
Color waitColour(
  BuildContext context,
  int minutes, {
  required int urgentMins,
  required int veryUrgentMins,
}) {
  final kitchen = context.kitchen;
  final critical = veryUrgentMins + (veryUrgentMins - urgentMins);
  if (minutes >= critical) return kitchen.ageUrgent;
  if (minutes >= veryUrgentMins) return kitchen.ageRed;
  if (minutes >= urgentMins) return kitchen.ageAmber;
  return kitchen.ageOk;
}

/// One line saying whether the kitchen is in trouble.
///
/// The old panel put four numbers on a screen and left the reading of them to
/// someone mid-service with their hands full.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.stats, required this.veryUrgentMins});

  final KitchenStats stats;
  final int veryUrgentMins;

  @override
  Widget build(BuildContext context) {
    final kitchen = context.kitchen;
    final colors = context.appColors;

    late final String headline;
    late final String detail;
    late final Color color;
    late final IconData icon;

    if (stats.isQuiet) {
      headline = 'Nothing on';
      detail = 'No open tickets and nothing bumped in the last hour.';
      color = colors.textSecondary;
      icon = Icons.bedtime_outlined;
    } else if (stats.overdue == 0) {
      headline = 'Keeping up';
      detail = 'Nothing has passed $veryUrgentMins minutes. '
          '${stats.linesToMake} lines to make.';
      color = kitchen.ageOk;
      icon = Icons.check_circle_outline;
    } else if (stats.overdue <= 2) {
      headline = '${stats.overdue} ticket${stats.overdue == 1 ? '' : 's'} '
          'running late';
      detail = 'The oldest has waited ${stats.oldestWaitMins} minutes.';
      color = kitchen.ageAmber;
      icon = Icons.error_outline;
    } else {
      headline = 'Backed up — ${stats.overdue} tickets late';
      detail = 'The oldest has waited ${stats.oldestWaitMins} minutes. '
          '${stats.linesToMake} lines still to make.';
      color = kitchen.ageRed;
      icon = Icons.priority_high_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline,
                    style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(detail,
                    style: TextStyle(
                        color: colors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Open tickets banded by wait, as one bar.
class _BandBar extends StatelessWidget {
  const _BandBar({
    required this.stats,
    required this.urgentMins,
    required this.veryUrgentMins,
  });

  final KitchenStats stats;
  final int urgentMins;
  final int veryUrgentMins;

  @override
  Widget build(BuildContext context) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    final critical = veryUrgentMins + (veryUrgentMins - urgentMins);

    final rows = <(WaitBand, String, Color)>[
      (WaitBand.onTime, 'Under $urgentMins min', kitchen.ageOk),
      (WaitBand.gettingOn, '$urgentMins–$veryUrgentMins min', kitchen.ageAmber),
      (WaitBand.late, '$veryUrgentMins–$critical min', kitchen.ageRed),
      (WaitBand.badlyLate, 'Over $critical min', kitchen.ageUrgent),
    ];
    final total = stats.byBand.values.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return _Empty(text: 'No tickets waiting.');
    }

    return Column(
      children: [
        // One bar, so the proportions are read rather than compared.
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                for (final (band, _, color) in rows)
                  if ((stats.byBand[band] ?? 0) > 0)
                    Expanded(
                      flex: stats.byBand[band]!,
                      child: Container(color: color),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final (band, label, color) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 13, color: colors.textSecondary)),
                ),
                Text(
                  '${stats.byBand[band] ?? 0}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: (stats.byBand[band] ?? 0) > 0
                          ? color
                          : colors.onDisabled),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lines by what has been done to them — the backed-up-at-one-status question.
class _StatusBreakdown extends StatelessWidget {
  const _StatusBreakdown({required this.stats});

  final KitchenStats stats;

  @override
  Widget build(BuildContext context) {
    final kitchen = context.kitchen;
    final colors = context.appColors;

    final rows = <(KitchenItemStatus, String, Color)>[
      (KitchenItemStatus.pending, 'Not started', kitchen.statusPending),
      (KitchenItemStatus.preparing, 'Being cooked', kitchen.statusPreparing),
      (KitchenItemStatus.held, 'Held for a course', kitchen.ageAmber),
      (KitchenItemStatus.completed, 'Done', kitchen.statusReady),
    ];
    final biggest = rows
        .map((r) => stats.linesByStatus[r.$1] ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);

    if (biggest == 0) return _Empty(text: 'No lines on the board.');

    return Column(
      children: [
        for (final (status, label, color) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 13, color: colors.textSecondary)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: stats.linesByStatus[status] ?? 0,
                            child: Container(color: color),
                          ),
                          Expanded(
                            flex: biggest - (stats.linesByStatus[status] ?? 0),
                            child: Container(color: colors.border),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${stats.linesByStatus[status] ?? 0}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Tickets away per ten minutes, oldest stretch on the left.
class _Throughput extends StatelessWidget {
  const _Throughput({required this.stats});

  final KitchenStats stats;

  @override
  Widget build(BuildContext context) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    final peak = stats.throughput
        .map((b) => b.bumped)
        .fold<int>(0, (a, b) => a > b ? a : b);

    if (peak == 0) {
      return _Empty(text: 'Nothing has gone out in the last hour.');
    }

    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bucket in stats.throughput) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${bucket.bumped}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: bucket.bumped == 0
                              ? colors.onDisabled
                              : colors.textPrimary)),
                  const SizedBox(height: 4),
                  // A floor of 3px, so an empty stretch is still a column a
                  // cook can see rather than a gap in the chart.
                  Container(
                    height: bucket.bumped == 0
                        ? 3
                        : 3 + (55 * bucket.bumped / peak),
                    decoration: BoxDecoration(
                      color: bucket.bumped == 0
                          ? colors.border
                          : kitchen.statusReady,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bucket.minutesAgo == 0 ? 'now' : '-${bucket.minutesAgo}m',
                    style:
                        TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// What the section is buried under.
class _Busiest extends StatelessWidget {
  const _Busiest({required this.stats});

  final KitchenStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final peak = stats.busiest.first.quantity;

    return Column(
      children: [
        for (final dish in stats.busiest)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text('${dish.quantity}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.primary)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dish.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13, color: colors.textPrimary)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 6,
                          child: Row(
                            children: [
                              Expanded(
                                flex: dish.quantity,
                                child: Container(color: colors.primary),
                              ),
                              Expanded(
                                flex: peak - dish.quantity,
                                child: Container(color: colors.border),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'across ${dish.tickets} '
                  '${dish.tickets == 1 ? 'ticket' : 'tickets'}',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(text,
            style: TextStyle(
                fontSize: 13, color: context.appColors.onDisabled)),
      );
}

class _Pending extends StatelessWidget {
  const _Pending();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 10),
            Text('Reading the last hour…',
                style: TextStyle(
                    fontSize: 13, color: context.appColors.textSecondary)),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    this.footnote,
  });

  final String label;
  final String value;
  final Color color;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 2,
                style: TextStyle(fontSize: 11, color: colors.textSecondary)),
            if (footnote != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(footnote!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 10, color: colors.onDisabled)),
              ),
          ],
        ),
      ),
    );
  }
}
