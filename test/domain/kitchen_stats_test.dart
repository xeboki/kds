import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/kitchen_stats.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';

final _now = DateTime.utc(2026, 10, 16, 19, 0);

KitchenOrderItem _line(
  String name, {
  int qty = 1,
  KitchenItemStatus status = KitchenItemStatus.pending,
  bool is86d = false,
  bool voided = false,
  List<String> routing = const ['grill'],
}) =>
    KitchenOrderItem(
      id: '$name-${status.name}-$qty-$is86d-$voided',
      orderId: 'o',
      productId: 'p-$name',
      productName: name,
      quantity: qty,
      status: status,
      is86d: is86d,
      isCancelled: voided,
      routingCategoryIds: routing,
    );

KitchenOrder _order(
  String id, {
  required int minsAgo,
  List<KitchenOrderItem> items = const [],
  KitchenOrderStatus status = KitchenOrderStatus.pending,
  DateTime? scheduledFor,
  DateTime? bumpedAt,
  DateTime? recalledAt,
}) =>
    KitchenOrder(
      id: id,
      orderId: id,
      orderNumber: id,
      locationId: 'loc',
      priority: KitchenOrderPriority.normal,
      status: status,
      orderTime: _now.subtract(Duration(minutes: minsAgo)),
      scheduledFor: scheduledFor,
      bumpedAt: bumpedAt,
      recalledAt: recalledAt,
      items: items,
    );

KitchenStats _stats({
  List<KitchenOrder> active = const [],
  List<KitchenOrder> bumped = const [],
  int urgent = 8,
  int veryUrgent = 15,
}) =>
    computeKitchenStats(
      active: active,
      bumped: bumped,
      routingCategoryIds: const ['grill'],
      isExpo: false,
      urgentMins: urgent,
      veryUrgentMins: veryUrgent,
      now: _now,
    );

void main() {
  group('an empty board', () {
    test('reports nothing rather than failing', () {
      final s = _stats();
      expect(s.openTickets, 0);
      expect(s.oldestWaitMins, 0);
      expect(s.medianWaitMins, 0);
      expect(s.averageTurnaroundMins, isNull);
      expect(s.busiest, isEmpty);
      expect(s.isQuiet, isTrue);
    });
  });

  group('waiting', () {
    test('bands each ticket against this screen\'s own rungs', () {
      // urgent 15, red 20 → deep red 25.
      final s = _stats(
        active: [
          _order('a', minsAgo: 2),
          _order('b', minsAgo: 17),
          _order('c', minsAgo: 22),
          _order('d', minsAgo: 40),
        ],
        urgent: 15,
        veryUrgent: 20,
      );
      expect(s.byBand[WaitBand.onTime], 1);
      expect(s.byBand[WaitBand.gettingOn], 1);
      expect(s.byBand[WaitBand.late], 1);
      expect(s.byBand[WaitBand.badlyLate], 1);
      expect(s.overdue, 2, reason: 'overdue is the red rungs, not amber');
    });

    test('the median is not the mean — one forgotten ticket cannot skew it',
        () {
      final s = _stats(active: [
        _order('a', minsAgo: 2),
        _order('b', minsAgo: 3),
        _order('c', minsAgo: 4),
        _order('d', minsAgo: 200),
      ]);
      expect(s.medianWaitMins, lessThan(10));
      expect(s.averageWaitMins, greaterThan(40));
      expect(s.oldestWaitMins, 200);
    });

    test('a ticket not due yet is counted apart, never as a wait', () {
      final s = _stats(active: [
        _order('now', minsAgo: 5),
        _order('later',
            minsAgo: 0, scheduledFor: _now.add(const Duration(hours: 3))),
      ]);
      expect(s.scheduledAhead, 1);
      expect(s.oldestWaitMins, 5,
          reason: 'a pre-order was counted as waiting and dwarfed the board');
      expect(s.byBand.values.fold<int>(0, (a, b) => a + b), 1);
    });

    test('a scheduled ticket past its time does wait, from the time asked',
        () {
      final s = _stats(active: [
        _order('due',
            minsAgo: 300,
            scheduledFor: _now.subtract(const Duration(minutes: 10))),
      ]);
      expect(s.scheduledAhead, 0);
      expect(s.oldestWaitMins, 10,
          reason: 'measured from when it was rung, not when it was wanted');
    });
  });

  group('lines', () {
    test('counts only what somebody still has to cook', () {
      final s = _stats(active: [
        _order('a', minsAgo: 1, items: [
          _line('Steak'),
          _line('Chips', status: KitchenItemStatus.preparing),
          _line('Peas', status: KitchenItemStatus.completed),
          _line('Soup', is86d: true),
          _line('Tart', voided: true),
        ]),
      ]);
      expect(s.linesToMake, 2, reason: 'done, 86\'d and voided are not work');
      expect(s.linesOff, 2);
      expect(s.linesByStatus[KitchenItemStatus.completed], 1);
      expect(s.linesByStatus[KitchenItemStatus.preparing], 1);
    });

    test('a held course is work not yet fired, so it still counts', () {
      final s = _stats(active: [
        _order('a', minsAgo: 1,
            items: [_line('Tart', status: KitchenItemStatus.held)]),
      ]);
      expect(s.linesToMake, 1);
      expect(s.linesByStatus[KitchenItemStatus.held], 1);
    });

    test('a prep screen counts only the lines it is responsible for', () {
      final s = computeKitchenStats(
        active: [
          _order('a', minsAgo: 1, items: [
            _line('Steak', routing: ['grill']),
            _line('Tart', routing: ['pastry']),
          ]),
        ],
        bumped: const [],
        routingCategoryIds: const ['grill'],
        isExpo: false,
        urgentMins: 8,
        veryUrgentMins: 15,
        now: _now,
      );
      expect(s.linesToMake, 1);
    });
  });

  group('busiest dishes', () {
    test('sums a dish across tickets, biggest first', () {
      final s = _stats(active: [
        _order('a', minsAgo: 1, items: [_line('Steak', qty: 2)]),
        _order('b', minsAgo: 2, items: [_line('Steak', qty: 3), _line('Pie')]),
      ]);
      expect(s.busiest.first.name, 'Steak');
      expect(s.busiest.first.quantity, 5);
      expect(s.busiest.first.tickets, 2);
    });

    test('a tie does not reshuffle between reads', () {
      final a = _stats(active: [
        _order('a', minsAgo: 1, items: [_line('Pie'), _line('Cod')]),
      ]);
      final b = _stats(active: [
        _order('a', minsAgo: 1, items: [_line('Cod'), _line('Pie')]),
      ]);
      expect(a.busiest.map((d) => d.name), b.busiest.map((d) => d.name));
    });

    test('shows at most five, so the panel cannot run away', () {
      final s = _stats(active: [
        _order('a', minsAgo: 1, items: [
          for (var i = 0; i < 12; i++) _line('Dish$i', qty: i + 1),
        ]),
      ]);
      expect(s.busiest.length, 5);
      expect(s.busiest.first.name, 'Dish11');
    });
  });

  group('the last hour', () {
    List<KitchenOrder> bumpedAt(List<int> minsAgo) => [
          for (var i = 0; i < minsAgo.length; i++)
            _order('b$i',
                minsAgo: minsAgo[i] + 5,
                status: KitchenOrderStatus.bumped,
                bumpedAt: _now.subtract(Duration(minutes: minsAgo[i]))),
        ];

    test('counts only what went out inside the hour', () {
      final s = _stats(bumped: bumpedAt([5, 20, 59, 61, 600]));
      expect(s.bumpedLastHour, 3);
    });

    test('buckets ten minutes at a time, oldest stretch first', () {
      final s = _stats(bumped: bumpedAt([1, 2, 15, 55]));
      expect(s.throughput.length, 6);
      expect(s.throughput.first.minutesAgo, 50);
      expect(s.throughput.last.minutesAgo, 0);
      expect(s.throughput.last.bumped, 2, reason: 'the stretch in progress');
      expect(s.throughput.first.bumped, 1, reason: '55 minutes ago');
    });

    test('turnaround is rung-to-away, averaged', () {
      final s = _stats(bumped: [
        _order('x',
            minsAgo: 30,
            status: KitchenOrderStatus.bumped,
            bumpedAt: _now.subtract(const Duration(minutes: 10))),
        _order('y',
            minsAgo: 40,
            status: KitchenOrderStatus.bumped,
            bumpedAt: _now.subtract(const Duration(minutes: 20))),
      ]);
      // 20 minutes and 20 minutes.
      expect(s.averageTurnaroundMins, 20);
    });

    test('a pre-order does not report a two-day turnaround', () {
      final s = _stats(bumped: [
        _order('pre',
            minsAgo: 2880,
            status: KitchenOrderStatus.bumped,
            scheduledFor: _now.subtract(const Duration(minutes: 15)),
            bumpedAt: _now.subtract(const Duration(minutes: 5))),
      ]);
      expect(s.averageTurnaroundMins, 10,
          reason: 'measured from when it was due, not when it was taken');
    });

    test('nothing out reads as no data, not as instant', () {
      expect(_stats().averageTurnaroundMins, isNull);
    });

    test('recalls are counted from when they were recalled', () {
      final s = _stats(active: [
        _order('r',
            minsAgo: 90,
            status: KitchenOrderStatus.recalled,
            recalledAt: _now.subtract(const Duration(minutes: 5))),
        // Recalled this morning, still on the board — not this hour's.
        _order('old',
            minsAgo: 600,
            status: KitchenOrderStatus.recalled,
            recalledAt: _now.subtract(const Duration(hours: 6))),
      ]);
      expect(s.recalledLastHour, 1);
    });
  });
}
