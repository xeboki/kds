// SPEC-020 — KDS's first real tests: KitchenOrder ticket-board pure logic.
// Deferred-tier: local unit tests only (no live prod). Run: cd KDS && flutter test.
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';

KitchenOrderItem _item({
  String id = 'i',
  KitchenItemStatus status = KitchenItemStatus.pending,
  String? stationId,
  int? courseNumber,
  List<KitchenItemModifier> modifiers = const [],
  String? specialInstructions,
  String? cookingPreference,
  int quantity = 1,
}) =>
    KitchenOrderItem(
      id: id,
      orderId: 'o',
      productId: 'p',
      productName: 'X',
      quantity: quantity,
      status: status,
      stationId: stationId,
      courseNumber: courseNumber,
      modifiers: modifiers,
      specialInstructions: specialInstructions,
      cookingPreference: cookingPreference,
    );

KitchenOrder _order({
  List<KitchenOrderItem> items = const [],
  DateTime? orderTime,
  DateTime? startedAt,
  DateTime? readyAt,
}) =>
    KitchenOrder(
      id: '1',
      orderId: 'o',
      locationId: 'l',
      orderNumber: '001',
      orderType: KitchenOrderType.dineIn,
      priority: KitchenOrderPriority.normal,
      status: KitchenOrderStatus.pending,
      orderTime: orderTime ?? DateTime.now(),
      items: items,
      startedAt: startedAt,
      readyAt: readyAt,
    );

KitchenItemModifier _mod() =>
    const KitchenItemModifier(id: 'm', name: 'No onions', action: ModifierAction.remove);

void main() {
  group('KitchenOrder.prepTimeMinutes', () {
    test('readyAt − startedAt in minutes', () {
      final o = _order(
        startedAt: DateTime(2026, 1, 1, 10, 0),
        readyAt: DateTime(2026, 1, 1, 10, 12),
      );
      expect(o.prepTimeMinutes, 12);
    });
    test('null when startedAt or readyAt missing', () {
      expect(_order(readyAt: DateTime(2026, 1, 1, 10, 12)).prepTimeMinutes, isNull);
      expect(_order(startedAt: DateTime(2026, 1, 1, 10, 0)).prepTimeMinutes, isNull);
    });
  });

  group('KitchenOrder.itemsByStation', () {
    test('filters to the station; empty for none', () {
      final o = _order(items: [
        _item(id: 'a', stationId: 'grill'),
        _item(id: 'b', stationId: 'fry'),
        _item(id: 'c', stationId: 'grill'),
      ]);
      expect(o.itemsByStation('grill').map((i) => i.id), ['a', 'c']);
      expect(o.itemsByStation('salad'), isEmpty);
    });
  });

  group('KitchenOrder.isComplete / completionPercentage', () {
    test('true when all items completed/cancelled', () {
      final o = _order(items: [
        _item(status: KitchenItemStatus.completed),
        _item(status: KitchenItemStatus.cancelled),
      ]);
      expect(o.isComplete, isTrue);
      expect(o.completionPercentage, 1.0);
    });
    test('false when any item still pending/preparing', () {
      final o = _order(items: [
        _item(status: KitchenItemStatus.completed),
        _item(status: KitchenItemStatus.preparing),
      ]);
      expect(o.isComplete, isFalse);
      expect(o.completionPercentage, 0.5);
    });
    test('mixed 2 of 4 → 0.5', () {
      final o = _order(items: [
        _item(status: KitchenItemStatus.completed),
        _item(status: KitchenItemStatus.cancelled),
        _item(status: KitchenItemStatus.pending),
        _item(status: KitchenItemStatus.held),
      ]);
      expect(o.completionPercentage, 0.5);
    });
    test('empty order edge: isComplete true, percentage 0 (every() on empty is true)', () {
      final o = _order(items: const []);
      expect(o.isComplete, isTrue);
      expect(o.completionPercentage, 0);
    });
  });

  group('KitchenOrder.byCourse', () {
    test('groups by courseNumber; null course defaults to 1', () {
      final o = _order(items: [
        _item(id: 'a', courseNumber: 1),
        _item(id: 'b', courseNumber: 2),
        _item(id: 'c', courseNumber: null), // → course 1
      ]);
      final byCourse = o.byCourse;
      expect(byCourse.keys.toSet(), {1, 2});
      expect(byCourse[1]!.map((i) => i.id).toSet(), {'a', 'c'});
      expect(byCourse[2]!.map((i) => i.id), ['b']);
    });
  });

  group('KitchenOrder.isUrgent / isVeryUrgent (controlled orderTime)', () {
    test('threshold comparison on wait time; isVeryUrgent behaves identically (pinned smell)', () {
      final o = _order(orderTime: DateTime.now().subtract(const Duration(minutes: 10)));
      expect(o.isUrgent(8), isTrue);     // waited ~10 ≥ 8
      expect(o.isUrgent(15), isFalse);   // ~10 < 15
      // isVeryUrgent has the SAME body as isUrgent — pins the copy-paste smell
      // (they only differ if callers pass different thresholds).
      expect(o.isVeryUrgent(8), o.isUrgent(8));
      expect(o.isVeryUrgent(15), o.isUrgent(15));
    });
  });

  group('KitchenOrderItem getters', () {
    test('hasModifiers', () {
      expect(_item(modifiers: const []).hasModifiers, isFalse);
      expect(_item(modifiers: [_mod()]).hasModifiers, isTrue);
    });
    test('hasSpecialInstructions', () {
      expect(_item(specialInstructions: null).hasSpecialInstructions, isFalse);
      expect(_item(specialInstructions: '').hasSpecialInstructions, isFalse);
      expect(_item(specialInstructions: 'allergy: nuts').hasSpecialInstructions, isTrue);
    });
    test('hasCookingPreference', () {
      expect(_item(cookingPreference: null).hasCookingPreference, isFalse);
      expect(_item(cookingPreference: 'well done').hasCookingPreference, isTrue);
    });
    test('isHeld', () {
      expect(_item(status: KitchenItemStatus.held).isHeld, isTrue);
      expect(_item(status: KitchenItemStatus.pending).isHeld, isFalse);
    });
  });

  // ───────────────────────────────────────────────────────────────────────
  // SPEC-020 Step-4 QA — edge cases beyond the happy path.
  // ───────────────────────────────────────────────────────────────────────
  group('Step-4 edges', () {
    test('prepTimeMinutes is negative when readyAt precedes startedAt (data anomaly, pinned)', () {
      final o = _order(
        startedAt: DateTime(2026, 1, 1, 10, 12),
        readyAt: DateTime(2026, 1, 1, 10, 0),
      );
      expect(o.prepTimeMinutes, -12);
    });

    test('itemsByStation excludes items with a null stationId', () {
      final o = _order(items: [
        _item(id: 'a', stationId: 'grill'),
        _item(id: 'b', stationId: null),
      ]);
      expect(o.itemsByStation('grill').map((i) => i.id), ['a']);
    });

    test('completionPercentage counts cancelled as done (all cancelled → 1.0)', () {
      final o = _order(items: [
        _item(status: KitchenItemStatus.cancelled),
        _item(status: KitchenItemStatus.cancelled),
      ]);
      expect(o.completionPercentage, 1.0);
    });

    test('byCourse with all null courses → single course-1 group', () {
      final o = _order(items: [
        _item(id: 'a', courseNumber: null),
        _item(id: 'b', courseNumber: null),
      ]);
      expect(o.byCourse.keys.toList(), [1]);
      expect(o.byCourse[1]!.length, 2);
    });

    test('a single held item makes the order incomplete', () {
      final o = _order(items: [_item(status: KitchenItemStatus.held)]);
      expect(o.isComplete, isFalse);
      expect(o.completionPercentage, 0);
    });
  });
}
