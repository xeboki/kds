/// The kitchen ticket builds, and prints the right lines.
///
/// SPEC-097 097-A. The till's equivalent threw for every order it was ever
/// given — `latin1.encode` on a U+2500 divider — and nothing noticed, because
/// its only caller is a print button that needs a restaurant, a printer and a
/// live order to reach. So the first test here does nothing but build one.
///
/// The second is the rule that matters in a kitchen with more than one screen:
/// a prep screen prints the lines it is responsible for, not the whole order.
/// Handing the grill a list of desserts is how a printed ticket stops being
/// read at all.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/domain/printing/kitchen_ticket_pdf.dart';

KitchenOrderItem _item(String name, {List<String> categories = const []}) =>
    KitchenOrderItem(
      id: 'i-$name',
      orderId: 'o1',
      productId: 'p-$name',
      productName: name,
      quantity: 1,
      status: KitchenItemStatus.pending,
      routingCategoryIds: categories,
    );

KitchenOrder _order(List<KitchenOrderItem> items) => KitchenOrder(
      id: 'doc1',
      orderId: 'o1',
      locationId: 'loc1',
      orderNumber: 'RCP00042',
      tableNumber: '7',
      priority: KitchenOrderPriority.normal,
      status: KitchenOrderStatus.pending,
      orderTime: DateTime.utc(2026, 10, 14, 9, 30),
      items: items,
    );

Future<List<int>> _build(
  KitchenOrder order, {
  List<String> screen = const [],
  bool isExpo = false,
}) =>
    buildKitchenTicketPdf(order,
        screenRoutingCategoryIds: screen,
        isExpo: isExpo,
        locationName: 'Bahria town Lahore');

void main() {
  test('builds a ticket at all, and it is a PDF', () async {
    final bytes = await _build(_order([_item('Breakfast Bap')]));
    expect(bytes, isNotEmpty);
    // A PDF starts with %PDF.
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('an urgent order still builds', () async {
    final order = _order([_item('Breakfast Bap')])
        .copyWith(priority: KitchenOrderPriority.urgent);
    expect(await _build(order), isNotEmpty);
  });

  test('every optional block together still builds', () async {
    final order = _order([
      _item('Steak'),
    ]).copyWith(
      specialInstructions: 'Table in a hurry',
      allergyInfo: 'Nuts',
      serverName: 'Rizwan',
      tableSectionName: 'Terrace',
    );
    expect(await _build(order), isNotEmpty);
  });

  test('an order with no lines for this screen still builds', () async {
    // A ticket printed from a screen that is responsible for none of it is
    // empty, not a crash.
    final order = _order([_item('Cheesecake', categories: ['dessert'])]);
    expect(await _build(order, screen: ['grill']), isNotEmpty);
  });

  test('a prep screen prints its own lines and the unclaimed ones', () async {
    // Proven by size rather than by reading the PDF: a ticket carrying two
    // lines is longer than the same ticket carrying one. Crude, but it is the
    // difference between the filter being applied and being ignored.
    final order = _order([
      _item('Steak', categories: ['grill']),
      _item('Cheesecake', categories: ['dessert']),
      _item('Bread'), // claimed by nobody — shows on every prep screen
    ]);

    final grill = await _build(order, screen: ['grill']);
    final expo = await _build(order, isExpo: true);

    // Expo assembles the order, so it carries all three.
    expect(expo.length, greaterThan(grill.length));
  });

  test('a non-Latin product name does not throw', () async {
    // The failure that killed the till's ESC/POS builder was an encoding one.
    final order = _order([_item('كباب')]);
    expect(await _build(order), isNotEmpty);
  });
}
