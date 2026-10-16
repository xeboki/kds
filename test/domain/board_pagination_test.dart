/// The board pages; it does not scroll.
///
/// A kitchen screen is read at a glance by someone holding a pan. The board
/// used to have a page scroll *and* an inner scroll inside every ticket, so
/// reaching the fourth line of the eleventh order was two gestures in two
/// nested surfaces. Toast's KDS paginates and lets a long ticket span several
/// grid slots; Square's own forums carry users who cannot reach the second
/// page of a long order at all.
///
/// These cover the packing, which is where a service of fifty either fits or
/// silently loses a ticket.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/board_pagination.dart';

KitchenOrder _order(String number, int lines) => KitchenOrder(
      id: number,
      orderId: number,
      locationId: 'loc',
      orderNumber: number,
      priority: KitchenOrderPriority.normal,
      status: KitchenOrderStatus.pending,
      orderTime: DateTime.utc(2026, 10, 16, 9),
      items: [
        for (var i = 0; i < lines; i++)
          KitchenOrderItem(
            id: '$number-$i',
            orderId: number,
            productId: 'p$i',
            productName: 'Item $i',
            quantity: 1,
            status: KitchenItemStatus.pending,
          ),
      ],
    );

/// A column that holds 15 lines — a 1080px-tall board at medium size.
const _capacity = 15;
const _size = 1;

List<BoardPage> _pages(List<KitchenOrder> orders,
        {int columns = 3, int capacity = _capacity}) =>
    paginate(orders,
        columns: columns,
        capacity: capacity,
        size: _size,
        screenRoutingCategoryIds: const [],
        isExpo: true);

int _cost(KitchenOrder o, {int capacity = _capacity}) => costOf(o,
    screenRoutingCategoryIds: const [],
    isExpo: true,
    capacity: capacity,
    size: _size);

void main() {
  group('what a ticket costs a column', () {
    test('its lines, plus the header and bump button', () {
      expect(_cost(_order('a', 1)), 1 + chromeInLines(_size));
      expect(_cost(_order('a', 6)), 6 + chromeInLines(_size));
    });

    test('a longer ticket costs proportionally more', () {
      // Costed in lines, not rounded to whole rows. Rounding made a six-line
      // ticket claim two rows of three and leave a row only a two-line ticket
      // could use — three tickets and two visible gaps on a page.
      final short = _cost(_order('a', 3));
      final long = _cost(_order('b', 9));
      expect(long - short, 6);
    });

    test('nothing is ever taller than the column', () {
      // The cap is the whole point: taller than the screen means either an
      // inner scroll or a page nobody can reach.
      expect(_cost(_order('a', 400)), _capacity);
    });

    test('a prep screen counts only its own lines', () {
      final order = _order('a', 20);
      final onGrill = costOf(order,
          screenRoutingCategoryIds: const ['grill'],
          isExpo: false,
          capacity: _capacity,
          size: _size);
      // None of these lines is claimed, so they all show — the unclaimed rule.
      expect(onGrill, greaterThan(1));
    });
  });

  group('packing a service', () {
    test('every ticket lands exactly once', () {
      final orders = [for (var i = 0; i < 50; i++) _order('o$i', 1 + i % 9)];
      final pages = _pages(orders, columns: 4);

      final placed = <String>[];
      for (final page in pages) {
        for (final column in page.columns) {
          placed.addAll(column.map((o) => o.orderNumber));
        }
      }
      expect(placed.length, orders.length,
          reason: 'a ticket was dropped or duplicated');
      expect(placed.toSet().length, orders.length);
    });

    test('no column is overfilled', () {
      final orders = [for (var i = 0; i < 40; i++) _order('o$i', 1 + i % 11)];
      final pages = _pages(orders, columns: 3);

      for (final page in pages) {
        for (final column in page.columns) {
          final used =
              column.fold<int>(0, (sum, o) => sum + _cost(o));
          expect(used, lessThanOrEqualTo(_capacity),
              reason: 'a column holds $used of $_capacity');
        }
      }
    });

    test('oldest first, reading down a column then across', () {
      final orders = [for (var i = 0; i < 9; i++) _order('o$i', 1)];
      final page = _pages(orders, columns: 3).first;
      expect(page.columns[0].map((o) => o.orderNumber), ['o0', 'o1', 'o2']);
      expect(page.columns[1].map((o) => o.orderNumber), ['o3', 'o4', 'o5']);
    });

    test('an empty board is one empty page, not none', () {
      // A board with no pages has nothing to render and no page indicator,
      // which reads as a broken screen rather than a quiet kitchen.
      final pages = _pages(const []);
      expect(pages, hasLength(1));
      expect(pages.single.isEmpty, isTrue);
    });

    test('a page is filled before the next one is started', () {
      // The fault this catches: a cursor that only moved forward sent
      // everything after one tall ticket onto a new page, and twenty-five
      // tickets spread over eight pages with two empty columns on each.
      //
      // The bar is two thirds, not full. Tickets are placed oldest first and
      // never reordered — a cook reads the board in the order food was rung —
      // so a three-slot ticket arriving when every column has one slot left
      // starts a new page and leaves a gap behind it. Backfilling that gap
      // with a later, smaller ticket would pack tighter and put a newer order
      // above an older one, which is the one thing this board must not do.
      final orders = [for (var i = 0; i < 25; i++) _order('o$i', 1 + i % 13)];
      const columns = 3;
      final pages = _pages(orders, columns: columns);

      int linesUsed(BoardPage page) => page.columns.fold(
            0,
            (sum, col) => sum + col.fold<int>(0, (s, o) => s + _cost(o)),
          );

      final total = columns * _capacity;
      for (final page in pages.take(pages.length - 1)) {
        final used = linesUsed(page);
        expect(used, greaterThanOrEqualTo((total * 2) ~/ 3),
            reason: 'a page carries only $used of $total line-heights');
      }
    });

    test('fifty small tickets need more than one page at 3x3', () {
      final pages = _pages([for (var i = 0; i < 50; i++) _order('o$i', 1)],
          columns: 3);
      expect(pages.length, greaterThan(1));
    });
  });
}
