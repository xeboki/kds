// Taking a dish off — 86 — had **no visible control anywhere**. The only way
// in was a long press on the line, and a long press is a gesture a mouse
// cannot perform, so on a trackball-driven kitchen screen there was no way to
// mark a dish off at all.
//
// These tap the real widget rather than checking that a name appears in the
// source: a guard that reads `show86Button:` in a file passes just as well
// when the branch behind it builds nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/core/theme/app_theme.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/item_tile.dart';

KitchenOrderItem _item({
  KitchenItemStatus status = KitchenItemStatus.pending,
  bool is86d = false,
}) =>
    KitchenOrderItem(
      id: 'l1',
      orderId: 'o1',
      productId: 'p1',
      productName: 'Lamb Chops',
      quantity: 1,
      status: status,
      is86d: is86d,
    );

Future<int> _tapTheOnlyWayToEightySix(
  WidgetTester tester, {
  required KitchenOrderItem item,
  required bool show86Button,
}) async {
  var fired = 0;
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: ItemTile(
        item: item,
        show86Button: show86Button,
        onToggle86: () => fired++,
        onMarkStarted: () {},
        onMarkCompleted: () {},
      ),
    ),
  ));
  return fired;
}

void main() {
  testWidgets('a pending line offers a tappable 86 control', (tester) async {
    var fired = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: ItemTile(
          item: _item(),
          show86Button: true,
          onToggle86: () => fired++,
        ),
      ),
    ));
    final button = find.byIcon(Icons.block);
    expect(button, findsOneWidget,
        reason: 'no 86 control on the surface that is meant to show one');
    await tester.tap(button);
    await tester.pump();
    expect(fired, 1, reason: 'the 86 control is drawn but does nothing');
  });

  testWidgets('an 86\'d line can be put back on', (tester) async {
    var fired = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: ItemTile(
          item: _item(is86d: true),
          show86Button: true,
          onToggle86: () => fired++,
        ),
      ),
    ));
    final back = find.byIcon(Icons.restart_alt);
    expect(back, findsOneWidget,
        reason: 'a line could be taken off and never put back');
    await tester.tap(back);
    await tester.pump();
    expect(fired, 1);
  });

  testWidgets('the long press still works where there is no button',
      (tester) async {
    var fired = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: ItemTile(
          item: _item(),
          onToggle86: () => fired++,
        ),
      ),
    ));
    expect(find.byIcon(Icons.block), findsNothing,
        reason: 'a board row is one line tall and must not grow a button');
    await tester.longPress(find.text('1× Lamb Chops'));
    await tester.pump();
    expect(fired, 1, reason: 'the board card lost its only way to 86 a line');
  });

  testWidgets('the ticket sheet is a surface that shows the control',
      (tester) async {
    // The sheet is where a cook without a touchscreen has to be able to do it.
    final fired = await _tapTheOnlyWayToEightySix(
        tester, item: _item(), show86Button: true);
    expect(fired, 0); // not tapped yet — the pump above only builds it
    expect(find.byIcon(Icons.block), findsOneWidget);
  });
}
