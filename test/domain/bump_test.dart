// One station's bump used to clear the ticket off every other station and
// off the pass. Proven on 34: STR00013, made by Bar and Fryer — the Bar
// bumps its drinks and the Fryer never sees the ticket again, so the food is
// never made and nobody at the pass knows.
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/bump.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';

KitchenOrderItem _line(
  String name, {
  required List<String> routing,
  KitchenItemStatus status = KitchenItemStatus.pending,
  bool is86d = false,
  bool voided = false,
}) =>
    KitchenOrderItem(
      id: name,
      orderId: 'o1',
      productId: 'p-$name',
      productName: name,
      quantity: 1,
      status: status,
      is86d: is86d,
      isCancelled: voided,
      routingCategoryIds: routing,
    );

KitchenOrder _order(
  List<KitchenOrderItem> items, {
  KitchenOrderStatus status = KitchenOrderStatus.pending,
}) =>
    KitchenOrder(
      id: 'o1',
      orderId: 'o1',
      orderNumber: 'STR00013',
      locationId: 'loc',
      priority: KitchenOrderPriority.normal,
      status: status,
      orderTime: DateTime.utc(2026, 10, 19, 19),
      items: items,
    );

void main() {
  group('a prep station bumps its own section', () {
    final twoSections = _order([
      _line('Lager', routing: ['bar']),
      _line('Wings', routing: ['fryer']),
    ]);

    test('it completes only the lines it is responsible for', () {
      final out = bumpOutcomeFor(
        order: twoSections,
        routingCategoryIds: const ['bar'],
        isExpo: false,
      );
      final byName = {for (final i in out.items) i.productName: i};
      expect(byName['Lager']!.status, KitchenItemStatus.completed);
      expect(byName['Wings']!.status, KitchenItemStatus.pending,
          reason: 'the bar bumped the fryer\'s food as well');
    });

    test('the ticket does not clear while another section still has work',
        () {
      final out = bumpOutcomeFor(
        order: twoSections,
        routingCategoryIds: const ['bar'],
        isExpo: false,
      );
      expect(out.clearsTicket, isFalse,
          reason: 'one station bumping took the ticket off the whole kitchen');
    });

    test('the last section to finish clears it', () {
      final afterBar = _order(bumpOutcomeFor(
        order: twoSections,
        routingCategoryIds: const ['bar'],
        isExpo: false,
      ).items);

      final out = bumpOutcomeFor(
        order: afterBar,
        routingCategoryIds: const ['fryer'],
        isExpo: false,
      );
      expect(out.clearsTicket, isTrue);
    });

    test('a one-screen kitchen behaves exactly as it always did', () {
      final out = bumpOutcomeFor(
        order: twoSections,
        routingCategoryIds: const ['bar', 'fryer'],
        isExpo: false,
      );
      expect(out.clearsTicket, isTrue);
      expect(out.items.every((i) => i.status == KitchenItemStatus.completed),
          isTrue);
    });

    test('a line nobody claimed is this screen\'s to bump', () {
      // The same rule that puts an unclaimed line on every prep screen.
      final out = bumpOutcomeFor(
        order: _order([_line('Mystery', routing: const [])]),
        routingCategoryIds: const ['bar'],
        isExpo: false,
      );
      expect(out.items.single.status, KitchenItemStatus.completed);
      expect(out.clearsTicket, isTrue);
    });

    test('86\'d and voided lines are not work, so they do not hold it open',
        () {
      final out = bumpOutcomeFor(
        order: _order([
          _line('Lager', routing: ['bar']),
          _line('Wings', routing: ['fryer'], is86d: true),
          _line('Tart', routing: ['pastry'], voided: true),
        ]),
        routingCategoryIds: const ['bar'],
        isExpo: false,
      );
      expect(out.clearsTicket, isTrue,
          reason: 'a ticket stayed on the board for food nobody will cook');
    });

    test('an already-completed line is left alone, not re-stamped', () {
      final done = _line('Lager',
          routing: ['bar'], status: KitchenItemStatus.completed);
      final out = bumpOutcomeFor(
        order: _order([done, _line('Wings', routing: ['fryer'])]),
        routingCategoryIds: const ['bar'],
        isExpo: false,
      );
      expect(out.items.first.completedAt, done.completedAt);
    });
  });

  group('the pass', () {
    test('expo clears the whole ticket, whatever the sections have done', () {
      final out = bumpOutcomeFor(
        order: _order([
          _line('Lager', routing: ['bar']),
          _line('Wings', routing: ['fryer']),
        ]),
        routingCategoryIds: const [],
        isExpo: true,
      );
      expect(out.clearsTicket, isTrue);
    });
  });

  group('what a prep screen still shows', () {
    test('a ticket it still has work on', () {
      expect(
        prepScreenShowsOrder(
          _order([
            _line('Lager', routing: ['bar']),
            _line('Wings', routing: ['fryer']),
          ]),
          const ['fryer'],
        ),
        isTrue,
      );
    });

    test('not one whose section is finished', () {
      expect(
        prepScreenShowsOrder(
          _order([
            _line('Lager', routing: ['bar']),
            _line('Wings',
                routing: ['fryer'], status: KitchenItemStatus.completed),
          ]),
          const ['fryer'],
        ),
        isFalse,
      );
    });

    test('the other section still sees it', () {
      final order = _order([
        _line('Lager', routing: ['bar']),
        _line('Wings',
            routing: ['fryer'], status: KitchenItemStatus.completed),
      ]);
      expect(prepScreenShowsOrder(order, const ['bar']), isTrue,
          reason: 'the fryer finishing took the ticket off the bar');
    });

    test('a recalled ticket comes back however its lines stand', () {
      final order = _order(
        [
          _line('Wings',
              routing: ['fryer'], status: KitchenItemStatus.completed),
        ],
        status: KitchenOrderStatus.recalled,
      );
      expect(prepScreenShowsOrder(order, const ['fryer']), isTrue,
          reason: 'recall could not bring a finished ticket back');
    });

    test('never one made entirely by another section', () {
      expect(
        prepScreenShowsOrder(
          _order([_line('Lager', routing: ['bar'])]),
          const ['pastry'],
        ),
        isFalse,
      );
    });
  });
}
