// SPEC-021 — the monorepo's first WIDGET test: KDS TimerBadge age/urgency
// coloring. Deferred-tier: local flutter test only. Run: cd KDS && flutter test.
//
// Timer hygiene: TimerBadge starts a Timer.periodic(1s) in initState and cancels
// it in dispose(). A testWidgets test fails with "A Timer is still pending" if
// the widget isn't unmounted — so each test ends with `pumpWidget(SizedBox())`
// to trigger dispose() and cancel the timer. (Reusable pattern for KDS widget
// tests.)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/core/theme/app_colors.dart';
import 'package:xeboki_kds/core/theme/app_theme.dart';
import 'package:xeboki_kds/core/theme/kds_theme.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/timer_badge.dart';

Future<void> _pumpBadge(
  WidgetTester tester,
  int minsAgo, {
  int urgent = 8,
  int veryUrgent = 15,
  int critical = 25,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: TimerBadge(
        orderTime: DateTime.now().subtract(Duration(minutes: minsAgo)),
        urgentMins: urgent,
        veryUrgentMins: veryUrgent,
        criticalMins: critical,
      ),
    ),
  ));
}

// The badge's Icon + Text are both painted with the band `_color`.
Color _badgeColor(WidgetTester tester) =>
    tester.widget<Icon>(find.byType(Icon)).color!;

Future<void> _disposeTimer(WidgetTester tester) async =>
    tester.pumpWidget(const SizedBox());

/// The same ramp the widgets read, at the brightness these tests
/// pump. Asserting a literal colour here would re-introduce the
/// second palette this app was just rid of.
const _kitchen = KitchenPalette(AppColors.light);

void main() {
  group('TimerBadge color band by age (default thresholds 8/15/25)', () {
    testWidgets('under 8 min → green (ageOk)', (tester) async {
      await _pumpBadge(tester, 3);
      expect(_badgeColor(tester), _kitchen.ageOk);
      await _disposeTimer(tester);
    });

    testWidgets('8–15 min → amber (ageAmber)', (tester) async {
      await _pumpBadge(tester, 10);
      expect(_badgeColor(tester), _kitchen.ageAmber);
      await _disposeTimer(tester);
    });

    testWidgets('15–25 min → red (ageRed)', (tester) async {
      await _pumpBadge(tester, 20);
      expect(_badgeColor(tester), _kitchen.ageRed);
      await _disposeTimer(tester);
    });

    testWidgets('25+ min → deep red (ageUrgent)', (tester) async {
      await _pumpBadge(tester, 30);
      expect(_badgeColor(tester), _kitchen.ageUrgent);
      await _disposeTimer(tester);
    });
  });

  testWidgets('custom thresholds are honored', (tester) async {
    // urgentMins lowered to 5 → a 6-minute-old ticket is amber (not green).
    await _pumpBadge(tester, 6, urgent: 5);
    expect(_badgeColor(tester), _kitchen.ageAmber);
    await _disposeTimer(tester);
  });

  testWidgets('label shows MM:SS reflecting elapsed minutes', (tester) async {
    await _pumpBadge(tester, 10);
    final label = tester.widget<Text>(find.byType(Text)).data!;
    expect(RegExp(r'^\d{2}:\d{2}$').hasMatch(label), isTrue, reason: 'label is MM:SS');
    final mins = int.parse(label.split(':')[0]);
    expect(mins, anyOf(9, 10), reason: '~10 min old, allowing 1-min clock drift');
    await _disposeTimer(tester);
  });

  // ───────────────────────────────────────────────────────────────────────
  // SPEC-021 Step-4 QA — near-boundary bands + structure + zero age.
  // Uses values 1 min above each threshold so a 1-min clock drift still lands
  // in the same band (>= threshold), avoiding flakiness at the exact edge.
  // ───────────────────────────────────────────────────────────────────────
  group('Step-4 near-boundary bands', () {
    testWidgets('just into amber (9 min)', (tester) async {
      await _pumpBadge(tester, 9);
      expect(_badgeColor(tester), _kitchen.ageAmber);
      await _disposeTimer(tester);
    });
    testWidgets('just into red (16 min)', (tester) async {
      await _pumpBadge(tester, 16);
      expect(_badgeColor(tester), _kitchen.ageRed);
      await _disposeTimer(tester);
    });
    testWidgets('just into deep red (26 min)', (tester) async {
      await _pumpBadge(tester, 26);
      expect(_badgeColor(tester), _kitchen.ageUrgent);
      await _disposeTimer(tester);
    });
  });

  testWidgets('brand-new ticket (0 min) is green', (tester) async {
    await _pumpBadge(tester, 0);
    expect(_badgeColor(tester), _kitchen.ageOk);
    await _disposeTimer(tester);
  });

  testWidgets('renders exactly one timer icon and one label', (tester) async {
    await _pumpBadge(tester, 5);
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    await _disposeTimer(tester);
  });
}
