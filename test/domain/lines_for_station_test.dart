/// Which lines a pinned screen shows.
///
/// SPEC-097. `itemsByStation` has been on this model since the board was
/// written and was called by nothing: every screen rendered `items`, so
/// pinning a screen to the grill still put the salads and the desserts in
/// front of it. Pinning was decoration.
///
/// Two cases must deliberately NOT be filtered out, and both are the kind of
/// bug that loses food rather than showing too much of it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';

KitchenOrderItem _line(String id, String? stationId, {int course = 1}) =>
    KitchenOrderItem(
      id: id,
      orderId: 'o1',
      productId: 'p_$id',
      productName: id,
      quantity: 1,
      status: KitchenItemStatus.pending,
      stationId: stationId,
      courseNumber: course,
    );

KitchenOrder _order(List<KitchenOrderItem> items) => KitchenOrder(
      id: 'o1',
      orderId: 'o1',
      locationId: 'loc1',
      orderNumber: 'A-1',
      orderType: KitchenOrderType.dineIn,
      priority: KitchenOrderPriority.normal,
      status: KitchenOrderStatus.pending,
      items: items,
      orderTime: DateTime(2026, 10, 13),
    );

void main() {
  final burger = _line('burger', 'st_grill');
  final salad = _line('salad', 'st_cold');
  final unrouted = _line('napkins', null);

  group('a pinned screen', () {
    test('shows its own station\'s lines', () {
      final lines = _order([burger, salad]).linesFor('st_grill');
      expect(lines.map((l) => l.id), ['burger']);
    });

    test('does not show another station\'s lines', () {
      final lines = _order([burger, salad]).linesFor('st_grill');
      expect(lines.any((l) => l.id == 'salad'), isFalse,
          reason: 'the grill is being shown the cold section\'s work');
    });

    test('STILL shows a line no station claimed', () {
      // The one that loses food. An unrouted line goes to every station by
      // design; hiding it here would put it on no screen at all and it would
      // simply never be cooked.
      final lines = _order([burger, unrouted]).linesFor('st_grill');
      expect(lines.map((l) => l.id), containsAll(['burger', 'napkins']));
    });
  });

  group('an unpinned screen', () {
    test('shows everything, whatever station each line is for', () {
      for (final pin in [null, '']) {
        final lines = _order([burger, salad, unrouted]).linesFor(pin);
        expect(lines.length, 3,
            reason: 'an expo or unpinned screen must assemble the whole order');
      }
    });
  });

  group('courses', () {
    test('are narrowed the same way the flat list is', () {
      final order = _order([
        _line('starter', 'st_grill', course: 1),
        _line('their starter', 'st_cold', course: 1),
        _line('main', 'st_grill', course: 2),
      ]);
      final courses = order.coursesFor('st_grill');
      expect(courses[1]!.map((l) => l.id), ['starter']);
      expect(courses[2]!.map((l) => l.id), ['main']);
    });

    test('a course with nothing for this station does not appear at all', () {
      final order = _order([
        _line('main', 'st_grill', course: 1),
        _line('pudding', 'st_dessert', course: 2),
      ]);
      expect(order.coursesFor('st_grill').keys, [1]);
    });

    test('an unpinned screen still sees every course', () {
      final order = _order([
        _line('main', 'st_grill', course: 1),
        _line('pudding', 'st_dessert', course: 2),
      ]);
      expect(order.coursesFor(null).keys.length, 2);
    });
  });
}
