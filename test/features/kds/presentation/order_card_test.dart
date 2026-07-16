// SPEC-022 — KDS OrderCard status-border widget tests. Establishes the
// ConsumerWidget + ProviderScope-override widget-test pattern (fake repo).
// Deferred-tier: local flutter test only. Run: cd KDS && flutter test.
//
// Timer hygiene: OrderCard embeds a TimerBadge (Timer.periodic) — each test
// unmounts via pumpWidget(SizedBox()) to cancel it (SPEC-021 pattern).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/core/theme/app_theme.dart';
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

void main() {
  testWidgets('renders inside ProviderScope with a fake repo (no provider error)', (tester) async {
    await _pumpCard(tester, KitchenOrderStatus.pending);
    expect(find.byType(OrderCard), findsOneWidget);
    await _disposeTimer(tester);
  });

  group('OrderCard status → border color', () {
    testWidgets('pending', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.pending);
      expect(_cardBorderColor(tester), KdsTheme.statusPending.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
    testWidgets('preparing', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.preparing);
      expect(_cardBorderColor(tester), KdsTheme.statusPreparing.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
    testWidgets('ready', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.ready);
      expect(_cardBorderColor(tester), KdsTheme.statusReady.withValues(alpha: 0.5));
      await _disposeTimer(tester);
    });
    testWidgets('recalled → red', (tester) async {
      await _pumpCard(tester, KitchenOrderStatus.recalled);
      expect(_cardBorderColor(tester), KdsTheme.ageRed.withValues(alpha: 0.5));
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
}
