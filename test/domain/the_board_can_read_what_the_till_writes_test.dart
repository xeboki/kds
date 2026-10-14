/// The kitchen screen can parse a ticket the till actually wrote.
///
/// SPEC-097. `KitchenOrder.orderType` was `required`, and **neither writer
/// emits a top-level `order_type`**: the till's own `KitchenOrder` has no such
/// field, and the API records it only inside `metadata`. With
/// `checked: true` a missing required field throws, so every real ticket took
/// the board down — it rendered blank grey and threw on every frame, rather
/// than showing an empty state or an error.
///
/// Found by ringing a dine-in sale on subscriber 34 and opening the board.
/// Nothing in either suite covered it, because both suites built their test
/// orders with the Dart constructor, which fills every required field by
/// definition. The only way to catch it is to parse the JSON a writer really
/// produces.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';

/// A ticket as the **till** writes it: `RestaurantTable`-era shape, no
/// `order_type` anywhere, snake_case throughout.
Map<String, dynamic> tillTicket() => {
      'id': 'KO1',
      'order_id': 'o1',
      'location_id': 'loc1',
      'order_number': 'RCP00044',
      'table_number': 'Walk 1',
      'priority': 'normal',
      'status': 'pending',
      'order_time': '2026-10-14T13:45:00.000Z',
      'routing_category_ids': ['rc_grill'],
      'items': [
        {
          'id': 'KO1_item_0',
          'order_id': 'o1',
          'product_id': 'p_bap',
          'product_name': 'Breakfast Bap',
          'quantity': 1,
          'status': 'pending',
          'routing_category_ids': ['rc_grill'],
          'is_unclaimed': false,
        },
        {
          'id': 'KO1_item_1',
          'order_id': 'o1',
          'product_id': 'p_scarf',
          'product_name': 'Last Season Scarf',
          'quantity': 1,
          'status': 'pending',
          'routing_category_ids': <String>[],
          'is_unclaimed': true,
        },
      ],
    };

void main() {
  test('a ticket with no order_type parses instead of throwing', () {
    final order = KitchenOrder.fromJson(tillTicket());
    expect(order.orderNumber, 'RCP00044');
    expect(order.items, hasLength(2));
  });

  test('its lines keep the routing the till stamped on them', () {
    final order = KitchenOrder.fromJson(tillTicket());
    expect(order.items.first.routingCategoryIds, ['rc_grill']);
    expect(order.items.first.isUnclaimed, isFalse);
    expect(order.items.last.routingCategoryIds, isEmpty);
    expect(order.items.last.isUnclaimed, isTrue,
        reason: 'the unclaimed line is the one that must still reach a screen');
  });

  test('a grill screen sees the grill line and the unclaimed one', () {
    final order = KitchenOrder.fromJson(tillTicket());
    final shown = order.linesFor(const ['rc_grill']).map((l) => l.productName);
    expect(shown, containsAll(['Breakfast Bap', 'Last Season Scarf']));
  });

  test('a screen for some other section sees only the unclaimed line', () {
    final order = KitchenOrder.fromJson(tillTicket());
    final shown = order.linesFor(const ['rc_fryer']).map((l) => l.productName);
    expect(shown, ['Last Season Scarf']);
  });

  test('an order_type that IS present is still read', () {
    final order =
        KitchenOrder.fromJson({...tillTicket(), 'order_type': 'takeaway'});
    expect(order.orderType, KitchenOrderType.takeaway);
  });
}
