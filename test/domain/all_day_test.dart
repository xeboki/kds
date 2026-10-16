/// The all-day count is the number a cook acts on.
///
/// Square describes it as "a count of a particular item across all tickets in
/// the queue that require preparation". Neither Square nor Toast headlines the
/// number of open orders — "twenty-five in the queue" is not something anybody
/// can do anything with, where "twelve flat whites" is: you pull twelve cups.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/all_day.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';

KitchenOrderItem _item(
  String name, {
  int qty = 1,
  KitchenItemStatus status = KitchenItemStatus.pending,
  bool is86d = false,
  List<String> categories = const [],
}) =>
    KitchenOrderItem(
      id: '$name-$qty-$status',
      orderId: 'o',
      productId: 'p-$name',
      productName: name,
      quantity: qty,
      status: status,
      is86d: is86d,
      routingCategoryIds: categories,
    );

KitchenOrder _order(String id, List<KitchenOrderItem> items) => KitchenOrder(
      id: id,
      orderId: id,
      locationId: 'loc',
      orderNumber: id,
      priority: KitchenOrderPriority.normal,
      status: KitchenOrderStatus.pending,
      orderTime: DateTime.utc(2026, 10, 16, 9),
      items: items,
    );

List<AllDayLine> _counts(List<KitchenOrder> orders,
        {List<String> screen = const [], bool isExpo = true}) =>
    allDayCounts(orders,
        screenRoutingCategoryIds: screen, isExpo: isExpo);

void main() {
  test('sums one product across every ticket', () {
    final lines = _counts([
      _order('a', [_item('Flat White', qty: 2)]),
      _order('b', [_item('Flat White', qty: 3)]),
      _order('c', [_item('Flat White', qty: 7)]),
    ]);
    expect(lines.single.productName, 'Flat White');
    expect(lines.single.quantity, 12);
    expect(lines.single.ticketCount, 3,
        reason: 'twelve on three tables reads differently from twelve on one');
  });

  test('biggest first, so a cook batches in that order', () {
    final lines = _counts([
      _order('a', [_item('Soup', qty: 1), _item('Steak', qty: 4)]),
      _order('b', [_item('Bread', qty: 9)]),
    ]);
    expect(lines.map((l) => l.productName), ['Bread', 'Steak', 'Soup']);
  });

  test('a tie does not reshuffle between reads', () {
    final lines = _counts([
      _order('a', [_item('Zucchini', qty: 2), _item('Apple', qty: 2)]),
    ]);
    expect(lines.map((l) => l.productName), ['Apple', 'Zucchini']);
  });

  test('work already done is not work', () {
    // Counting a completed, cancelled or 86'd line inflates the number a cook
    // is pulling stock against — worse than not showing it at all.
    final lines = _counts([
      _order('a', [
        _item('Steak', qty: 2),
        _item('Steak', qty: 5, status: KitchenItemStatus.completed),
        _item('Steak', qty: 9, status: KitchenItemStatus.cancelled),
        _item('Steak', qty: 4, is86d: true),
      ]),
    ]);
    expect(lines.single.quantity, 2);
  });

  test('a held course still counts — it is work not yet fired', () {
    final lines = _counts([
      _order('a', [_item('Dessert', qty: 3, status: KitchenItemStatus.held)]),
    ]);
    expect(lines.single.quantity, 3);
  });

  test('a prep screen counts only what it is responsible for', () {
    final orders = [
      _order('a', [
        _item('Steak', qty: 2, categories: ['grill']),
        _item('Cheesecake', qty: 6, categories: ['dessert']),
      ]),
    ];
    final grill = allDayCounts(orders,
        screenRoutingCategoryIds: const ['grill'], isExpo: false);
    expect(grill.map((l) => l.productName), ['Steak']);

    // The pass assembles the order and sees both.
    expect(_counts(orders).length, 2);
  });

  test('an empty board counts nothing rather than failing', () {
    expect(_counts(const []), isEmpty);
  });
}
