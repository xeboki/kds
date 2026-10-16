// A kitchen screen carries almost all of its state in a coloured dot and a
// three-letter badge, and a cook on their first night has no way to look any
// of it up mid-service. Every one of them must say what it means on hover.
//
// These pump the real tile and read the Tooltip, rather than checking that a
// string appears in a file: a tooltip wired with an empty message renders
// nothing and would pass a source check.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/core/theme/app_theme.dart';
import 'package:xeboki_kds/features/kds/domain/line_meanings.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/item_tile.dart';

KitchenOrderItem _item({
  KitchenItemStatus status = KitchenItemStatus.pending,
  bool is86d = false,
  bool isCancelled = false,
  bool isNewlyAdded = false,
  bool isModified = false,
}) =>
    KitchenOrderItem(
      id: 'l1',
      orderId: 'o1',
      productId: 'p1',
      productName: 'Lamb Chops',
      quantity: 1,
      status: status,
      is86d: is86d,
      isCancelled: isCancelled,
      isNewlyAdded: isNewlyAdded,
      isModified: isModified,
    );

Future<List<String>> _tooltips(WidgetTester tester, KitchenOrderItem i) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: ItemTile(item: i, onToggle86: () {})),
  ));
  return tester
      .widgetList<Tooltip>(find.byType(Tooltip))
      .map((t) => t.message ?? '')
      .where((m) => m.isNotEmpty)
      .toList();
}

void main() {
  test('every line status has words for it', () {
    for (final s in KitchenItemStatus.values) {
      expect(statusMeaning(s).trim(), isNotEmpty,
          reason: '$s is drawn on the board and explained nowhere');
    }
  });

  testWidgets('the status dot explains itself on hover', (tester) async {
    for (final status in KitchenItemStatus.values) {
      final tips = await _tooltips(tester, _item(status: status));
      // A cancelled line is a void, and the dot deliberately gives the
      // fuller wording — "do not cook it" matters more than the word.
      final want = status == KitchenItemStatus.cancelled
          ? voidMeaning
          : statusMeaning(status);
      expect(tips, contains(want),
          reason: 'a $status line has no hover explanation');
    }
  });

  testWidgets("an 86'd line explains the badge, not just the dot",
      (tester) async {
    final tips = await _tooltips(tester, _item(is86d: true));
    expect(tips.where((t) => t == eightySixMeaning).length, greaterThan(0));
  });

  testWidgets('a voided line explains itself', (tester) async {
    final tips = await _tooltips(tester, _item(isCancelled: true));
    expect(tips, contains(voidMeaning));
  });

  testWidgets('NEW and MOD explain themselves', (tester) async {
    expect(await _tooltips(tester, _item(isNewlyAdded: true)),
        contains(newlyAddedMeaning));
    expect(await _tooltips(tester, _item(isModified: true)),
        contains(modifiedMeaning));
  });

  group('the timer says why it is the colour it is', () {
    test('it quotes this screen\'s own rungs, not the defaults', () {
      final m = timerMeaning(
          minutes: 22, countingDown: false, urgentMins: 15, veryUrgentMins: 20);
      expect(m, contains('15'));
      expect(m, contains('20'));
      expect(m, contains('25')); // the derived deep-red rung
      expect(m, contains('late'));
    });

    test('a ticket not yet due says so rather than naming a colour', () {
      final m = timerMeaning(
          minutes: 180, countingDown: true, urgentMins: 8, veryUrgentMins: 15);
      expect(m.toLowerCase(), contains('not due yet'));
    });

    test('each rung reads differently from the one below', () {
      String at(int mins) => timerMeaning(
          minutes: mins, countingDown: false, urgentMins: 8, veryUrgentMins: 15);
      final said = {at(1), at(9), at(16), at(30)};
      expect(said.length, 4, reason: 'two rungs read the same to a cook');
    });
  });
}
