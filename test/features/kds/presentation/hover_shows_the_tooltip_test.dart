// The explanations must actually *appear* on hover, not merely be attached.
//
// A Tooltip with the right message still shows nothing if something above it
// eats the pointer, and the semantics tree looks identical either way — so
// this drives a real mouse pointer and reads the overlay.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/core/theme/app_theme.dart';
import 'package:xeboki_kds/features/kds/domain/line_meanings.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/item_tile.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/timer_badge.dart';

Future<void> _hover(WidgetTester tester, Finder target) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await tester.pump();
  await mouse.moveTo(tester.getCenter(target));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hovering a line shows what its status means', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: ItemTile(
          item: const KitchenOrderItem(
            id: 'l1',
            orderId: 'o1',
            productId: 'p1',
            productName: 'Lamb Chops',
            quantity: 1,
            status: KitchenItemStatus.preparing,
          ),
          onToggle86: () {},
        ),
      ),
    ));

    await _hover(tester, find.text('1× Lamb Chops'));
    expect(find.text(statusMeaning(KitchenItemStatus.preparing)), findsWidgets,
        reason: 'the explanation is attached but never appears on hover');
  });

  testWidgets('hovering the timer explains the colour', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: TimerBadge(
            dueAt: DateTime.now().subtract(const Duration(minutes: 22)),
            urgentMins: 15,
            veryUrgentMins: 20,
          ),
        ),
      ),
    ));

    await _hover(tester, find.byType(TimerBadge));
    final want = timerMeaning(
        minutes: 22, countingDown: false, urgentMins: 15, veryUrgentMins: 20);
    expect(find.text(want), findsWidgets,
        reason: 'the timer never says why it is red');
    await tester.pumpWidget(const SizedBox()); // cancel the 1s ticker
  });
}
