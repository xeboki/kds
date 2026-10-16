// Two things the panel has to get right that a unit test on the figures
// cannot see:
//
//   * an hour that has not been read yet must not read as an hour in which
//     nothing happened — "0 away, last hour" mid-service is worse than
//     saying nothing;
//   * on a kitchen display the whole picture has to fit without scrolling,
//     which means the column count has to divide the number of sections. At
//     three columns the four sections dealt 2/1/1 and the tallest ran off
//     the bottom while two columns sat empty.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xeboki_kds/core/theme/app_theme.dart';
import 'package:xeboki_kds/features/kds/domain/kitchen_stats.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/analytics_panel.dart';

KitchenOrder _order(String id, {int minsAgo = 5}) => KitchenOrder(
      id: id,
      orderId: id,
      orderNumber: id,
      locationId: 'loc',
      priority: KitchenOrderPriority.normal,
      status: KitchenOrderStatus.pending,
      orderTime: DateTime.now().toUtc().subtract(Duration(minutes: minsAgo)),
      items: [
        KitchenOrderItem(
          id: '$id-1',
          orderId: id,
          productId: 'p',
          productName: 'Lamb Chops',
          quantity: 2,
          status: KitchenItemStatus.pending,
          routingCategoryIds: const ['grill'],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, Size size,
    {required bool historyLoaded}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: AnalyticsBody(
          stats: computeKitchenStats(
            active: [_order('a'), _order('b', minsAgo: 40)],
            bumped: const [],
            routingCategoryIds: const ['grill'],
            isExpo: false,
            urgentMins: 8,
            veryUrgentMins: 15,
          ),
          urgentMins: 8,
          veryUrgentMins: 15,
          historyLoaded: historyLoaded,
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('an unread hour shows nothing, not zero', (tester) async {
    await _pump(tester, const Size(1580, 900), historyLoaded: false);

    expect(find.text('Reading the last hour…'), findsOneWidget);

    // The figures beneath must not claim an empty hour. Asked of those
    // figures specifically — the panel has honest zeroes elsewhere, in the
    // band counts and the chart buckets.
    for (final label in ['away, last hour', 'recalled', 'rung to away']) {
      final value = find.descendant(
        of: find.byKey(ValueKey('figure-$label')),
        matching: find.byType(Text),
      );
      expect(tester.widgetList<Text>(value).first.data, '—',
          reason: '"$label" reported an unread hour as an empty one');
    }
  });

  testWidgets('a read hour shows its figures', (tester) async {
    await _pump(tester, const Size(1580, 900), historyLoaded: true);
    expect(find.text('Reading the last hour…'), findsNothing);
    final value = find.descendant(
      of: find.byKey(const ValueKey('figure-away, last hour')),
      matching: find.byType(Text),
    );
    expect(tester.widgetList<Text>(value).first.data, '0',
        reason: 'a read hour with nothing in it is a real zero');
  });

  testWidgets('every section is on screen at kitchen-display width',
      (tester) async {
    await _pump(tester, const Size(1580, 900), historyLoaded: true);

    for (final title in [
      'HOW FAR BEHIND',
      'WHERE THE WORK IS',
      'GOING OUT',
      'BURIED UNDER',
    ]) {
      expect(find.text(title), findsOneWidget, reason: '$title is missing');
    }
  });

  testWidgets('the sections deal evenly — no column is left empty',
      (tester) async {
    await _pump(tester, const Size(1580, 900), historyLoaded: true);

    // Four sections across four columns: each heading sits at its own x.
    final xs = [
      for (final t in [
        'HOW FAR BEHIND',
        'WHERE THE WORK IS',
        'GOING OUT',
        'BURIED UNDER',
      ])
        tester.getTopLeft(find.text(t)).dx,
    ];
    expect(xs.toSet().length, 4,
        reason: 'two sections stacked in one column while another sat empty');
  });

  testWidgets('a narrow screen stacks them instead of squeezing',
      (tester) async {
    await _pump(tester, const Size(600, 1400), historyLoaded: true);

    final xs = [
      for (final t in ['HOW FAR BEHIND', 'WHERE THE WORK IS'])
        tester.getTopLeft(find.text(t)).dx,
    ];
    expect(xs.first, xs.last,
        reason: 'sections were put side by side on a narrow screen');
  });
}
