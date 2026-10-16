import 'models/kitchen_order.dart';

/// How a ticket's wait reads against this screen's own rungs.
enum WaitBand { onTime, gettingOn, late, badlyLate }

/// One slice of the throughput chart.
class ThroughputBucket {
  const ThroughputBucket({required this.minutesAgo, required this.bumped});

  /// Minutes before now that this bucket *starts*, so 50 is the oldest of
  /// six ten-minute buckets and 0 is the one in progress.
  final int minutesAgo;
  final int bumped;
}

/// A dish and how much of it is still to make.
class DishLoad {
  const DishLoad({
    required this.name,
    required this.quantity,
    required this.tickets,
  });

  final String name;
  final int quantity;
  final int tickets;
}

/// Everything the panel shows, worked out once.
///
/// Derived from the two lists the board already watches, so it cannot
/// disagree with the cards on screen, and scoped the same way — a grill
/// screen reports the grill's backlog, an expo screen reports the pass.
class KitchenStats {
  const KitchenStats({
    required this.openTickets,
    required this.linesToMake,
    required this.scheduledAhead,
    required this.oldestWaitMins,
    required this.averageWaitMins,
    required this.medianWaitMins,
    required this.byBand,
    required this.linesByStatus,
    required this.linesOff,
    required this.bumpedLastHour,
    required this.recalledLastHour,
    required this.throughput,
    required this.averageTurnaroundMins,
    required this.busiest,
  });

  final int openTickets;

  /// Lines somebody still has to cook: not done, not 86'd, not voided.
  final int linesToMake;

  /// On the board but not due yet, so excluded from every wait figure.
  final int scheduledAhead;

  final int oldestWaitMins;
  final int averageWaitMins;

  /// The middle ticket. An average is dragged by one forgotten ticket; the
  /// median says what a normal table is actually waiting.
  final int medianWaitMins;

  final Map<WaitBand, int> byBand;
  final Map<KitchenItemStatus, int> linesByStatus;
  final int linesOff;

  final int bumpedLastHour;
  final int recalledLastHour;
  final List<ThroughputBucket> throughput;

  /// Rung to away, averaged over the last hour. Null when nothing went out,
  /// because a zero there would read as "instant" rather than "no data".
  final int? averageTurnaroundMins;

  final List<DishLoad> busiest;

  /// Tickets past the red rung — the number a head chef acts on.
  int get overdue =>
      (byBand[WaitBand.late] ?? 0) + (byBand[WaitBand.badlyLate] ?? 0);

  bool get isQuiet => openTickets == 0 && bumpedLastHour == 0;
}

/// Work out the whole panel from the board.
///
/// [now] is injectable so the figures can be tested without waiting an hour.
KitchenStats computeKitchenStats({
  required List<KitchenOrder> active,
  required List<KitchenOrder> bumped,
  required List<String> routingCategoryIds,
  required bool isExpo,
  required int urgentMins,
  required int veryUrgentMins,
  DateTime? now,
}) {
  final clock = (now ?? DateTime.now()).toUtc();
  final criticalMins = veryUrgentMins + (veryUrgentMins - urgentMins);
  final hourAgo = clock.subtract(const Duration(hours: 1));

  // ── Waiting ────────────────────────────────────────────────────────────────
  // A ticket asked for a later time is not waiting, it is booked. Including
  // it made the oldest wait read in days.
  //
  // Judged against [clock], not `isScheduledAhead` — that getter reads the
  // real `DateTime.now()`, so half this function would have run on a
  // different clock from the other half and no test could pin it down.
  bool aheadOfItsTime(KitchenOrder o) =>
      o.scheduledFor != null && o.scheduledFor!.toUtc().isAfter(clock);

  final waiting = active.where((o) => !aheadOfItsTime(o)).toList();
  final waits = waiting
      .map((o) => clock.difference(o.dueAt.toUtc()).inMinutes)
      .toList()
    ..sort();

  final byBand = <WaitBand, int>{for (final b in WaitBand.values) b: 0};
  for (final mins in waits) {
    final band = mins >= criticalMins
        ? WaitBand.badlyLate
        : mins >= veryUrgentMins
            ? WaitBand.late
            : mins >= urgentMins
                ? WaitBand.gettingOn
                : WaitBand.onTime;
    byBand[band] = byBand[band]! + 1;
  }

  // ── Lines ──────────────────────────────────────────────────────────────────
  final linesByStatus = <KitchenItemStatus, int>{
    for (final s in KitchenItemStatus.values) s: 0,
  };
  var linesToMake = 0;
  var linesOff = 0;
  final quantities = <String, int>{};
  final ticketsPerDish = <String, Set<String>>{};

  for (final order in active) {
    for (final line in order.linesFor(routingCategoryIds, isExpo: isExpo)) {
      if (line.isOff) {
        linesOff++;
        continue;
      }
      linesByStatus[line.status] = (linesByStatus[line.status] ?? 0) + 1;
      if (line.status == KitchenItemStatus.completed) continue;
      linesToMake++;
      quantities[line.productName] =
          (quantities[line.productName] ?? 0) + line.quantity;
      ticketsPerDish
          .putIfAbsent(line.productName, () => <String>{})
          .add(order.id);
    }
  }

  final busiest = quantities.entries
      .map((e) => DishLoad(
            name: e.key,
            quantity: e.value,
            tickets: ticketsPerDish[e.key]?.length ?? 0,
          ))
      .toList()
    // Biggest first, then by name so a tie does not reshuffle between reads.
    ..sort((a, b) => a.quantity == b.quantity
        ? a.name.compareTo(b.name)
        : b.quantity.compareTo(a.quantity));

  // ── The last hour ──────────────────────────────────────────────────────────
  final bumpedRecently = bumped
      .where((o) => o.bumpedAt != null && o.bumpedAt!.toUtc().isAfter(hourAgo))
      .toList();

  // Six ten-minute buckets. Bucket 0 is the one in progress.
  final buckets = List<int>.filled(6, 0);
  for (final order in bumpedRecently) {
    final age = clock.difference(order.bumpedAt!.toUtc()).inMinutes;
    final slot = age ~/ 10;
    if (slot >= 0 && slot < buckets.length) buckets[slot]++;
  }

  // Rung to away. Measured from `dueAt`, so a pre-order does not report a
  // two-day turnaround for having been taken on Thursday.
  final turnarounds = bumpedRecently
      .map((o) => o.bumpedAt!.toUtc().difference(o.dueAt.toUtc()).inMinutes)
      .where((m) => m >= 0)
      .toList();

  final recalledRecently = active
      .where((o) =>
          o.status == KitchenOrderStatus.recalled &&
          o.recalledAt != null &&
          o.recalledAt!.toUtc().isAfter(hourAgo))
      .length;

  return KitchenStats(
    openTickets: active.length,
    linesToMake: linesToMake,
    scheduledAhead: active.where(aheadOfItsTime).length,
    oldestWaitMins: waits.isEmpty ? 0 : waits.last,
    averageWaitMins:
        waits.isEmpty ? 0 : waits.reduce((a, b) => a + b) ~/ waits.length,
    medianWaitMins: waits.isEmpty ? 0 : waits[waits.length ~/ 2],
    byBand: byBand,
    linesByStatus: linesByStatus,
    linesOff: linesOff,
    bumpedLastHour: bumpedRecently.length,
    recalledLastHour: recalledRecently,
    throughput: [
      for (var i = buckets.length - 1; i >= 0; i--)
        ThroughputBucket(minutesAgo: i * 10, bumped: buckets[i]),
    ],
    averageTurnaroundMins: turnarounds.isEmpty
        ? null
        : turnarounds.reduce((a, b) => a + b) ~/ turnarounds.length,
    busiest: busiest.take(5).toList(),
  );
}
