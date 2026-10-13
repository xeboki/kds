// SPEC-022 — KDS OrderCard status-border widget tests. Establishes the
// ConsumerWidget + ProviderScope-override widget-test pattern (fake repo).
// Deferred-tier: local flutter test only. Run: cd KDS && flutter test.
//
// Timer hygiene: OrderCard embeds a TimerBadge (Timer.periodic) — each test
// unmounts via pumpWidget(SizedBox()) to cancel it (SPEC-021 pattern).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/core/theme/app_colors.dart';
import 'package:xeboki_kds/core/theme/kds_theme.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/domain/repositories/kitchen_repository.dart';
import 'package:xeboki_kds/features/kds/presentation/providers/kitchen_providers.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/order_card.dart';

// Minimal fake: OrderCard reads the repo to wire tap callbacks but calls no
// method during a static render, so noSuchMethod (never hit here) is enough.
class _FakeKitchenRepository implements KitchenRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

KitchenOrder _order(KitchenOrderStatus status) => KitchenOrder(
      id: '1',
      orderId: 'o',
      locationId: 'l',
      orderNumber: '001',
      orderType: KitchenOrderType.dineIn,
      priority: KitchenOrderPriority.normal,
      status: status,
      orderTime: DateTime.now(),
      items: const [],
    );

Future<void> _pumpCard(WidgetTester tester, KitchenOrderStatus status) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [kitchenRepositoryProvider.overrideWithValue(_FakeKitchenRepository())],
      child: MaterialApp(home: Scaffold(body: OrderCard(order: _order(status)))),
    ),
  );
}

// The card's own border is the one with width 1.5 (see OrderCard.build).
Color _cardBorderColor(WidgetTester tester) {
  final card = tester.widgetList<Container>(find.byType(Container)).firstWhere((c) {
    final d = c.decoration;
    return d is BoxDecoration && d.border is Border && (d.border as Border).top.width == 1.5;
  });
  return ((card.decoration as BoxDecoration).border as Border).top.color;
}

Future<void> _disposeTimer(WidgetTester tester) async =>
    tester.pumpWidget(const SizedBox());

/// The same ramp the widgets read, at the brightness these tests
/// pump. Asserting a literal colour here would re-introduce the
/// second palette this app was just rid of.
const _kitchen = KitchenPalette(AppColors.light);

void main() {
  testWidgets('renders inside ProviderScope with a fake repo (no provider error)', (tester) async {
    await _pumpCard(tester, KitchenOrderStatus.pending);
    expect(find.byType(OrderCard), findsOneWidget);
    await _disposeTimer(tester);
  });

  group('OrderCard status → border color', () {
    testWidgets('pending', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.pending);
      expect(_cardBorderColor(tester), _kitchen.statusPending.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
    testWidgets('preparing', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.preparing);
      expect(_cardBorderColor(tester), _kitchen.statusPreparing.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
    testWidgets('ready', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.ready);
      expect(_cardBorderColor(tester), _kitchen.statusReady.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
    testWidgets('recalled → red', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.recalled);
      expect(_cardBorderColor(tester), _kitchen.ageRed.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
    testWidgets('other status (served) → transparent', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.served);
      expect(_cardBorderColor(tester), Colors.transparent.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
  });

  // ───────────────────────────────────────────────────────────────────────
  // SPEC-022 Step-4 QA — the remaining default-branch statuses + structure.
  // ───────────────────────────────────────────────────────────────────────
  group('Step-4 remaining statuses (default → transparent)', () {
    for (final status in [KitchenOrderStatus.bumped, KitchenOrderStatus.cancelled]) {
      testWidgets('$status → transparent', (tester) async {
        await _pumpCard(tester, status);
        expect(_cardBorderColor(tester), Colors.transparent.withValues(alpha: 0.5));
        await _disposeTimer(tester);
      });
    }
  });

  testWidgets('renders the order content (order number visible)', (tester) async {
    await _pumpCard(tester, KitchenOrderStatus.pending);
    expect(find.textContaining('001'), findsWidgets);
    await _disposeTimer(tester);
  });

  testWidgets('a prep card shows a line in a category it is on for',
      (tester) async {
    await _pumpMixed(tester, const ['rc_grill']);
    expect(find.textContaining('Burger'), findsOneWidget);
    await _disposeTimer(tester);
  });

  testWidgets('a prep card hides another category\'s line', (tester) async {
    await _pumpMixed(tester, const ['rc_grill']);
    expect(find.textContaining('Salad'), findsNothing,
        reason: 'the grill is being shown the cold section\'s work — the card '
            'is rendering every line again instead of this screen\'s');
    await _disposeTimer(tester);
  });

  testWidgets('a prep card still shows an unclaimed line', (tester) async {
    await _pumpMixed(tester, const ['rc_grill']);
    expect(find.textContaining('Napkins'), findsOneWidget,
        reason: 'a line no station claimed is on no screen at all, so nobody '
            'would make it');
    await _disposeTimer(tester);
  });

  testWidgets('an expo card shows every line', (tester) async {
    await _pumpMixed(tester, const [], isExpo: true);
    for (final name in ['Burger', 'Salad', 'Napkins']) {
      expect(find.textContaining(name), findsOneWidget,
          reason: 'an expo screen must assemble the whole order');
    }
    await _disposeTimer(tester);
  });
}

// ── SPEC-097: the card renders ONE station's lines ──────────────────────────
//
// `linesFor` / `coursesFor` are covered by test/domain, but a unit test of a
// helper nothing calls proves nothing: reverting the card to `order.items`
// left every one of those tests green while the grill cook saw the desserts
// again. This is the test that fails for that, so it renders the widget and
// reads what is on the screen.

KitchenOrderItem _routedLine(String name, List<String> routingCategoryIds) =>
    KitchenOrderItem(
      id: name,
      orderId: 'o',
      productId: 'p_$name',
      productName: name,
      quantity: 1,
      status: KitchenItemStatus.pending,
      routingCategoryIds: routingCategoryIds,
      isUnclaimed: routingCategoryIds.isEmpty,
    );

KitchenOrder _mixedOrder() => KitchenOrder(
      id: '1',
      orderId: 'o',
      locationId: 'l',
      orderNumber: '001',
      orderType: KitchenOrderType.dineIn,
      priority: KitchenOrderPriority.normal,
      status: KitchenOrderStatus.pending,
      orderTime: DateTime.now(),
      items: [
        _routedLine('Burger', const ['rc_grill']),
        _routedLine('Salad', const ['rc_cold']),
        _routedLine('Napkins', const []),
      ],
    );

Future<void> _pumpMixed(WidgetTester tester, List<String> routingCategoryIds,
    {bool isExpo = false}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kitchenRepositoryProvider.overrideWithValue(_FakeKitchenRepository())
      ],
      child: MaterialApp(
        home: Scaffold(
          body: OrderCard(
            order: _mixedOrder(),
            routingCategoryIds: routingCategoryIds,
            isExpo: isExpo,
          ),
        ),
      ),
    ),
  );
}
