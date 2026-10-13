/// Which lines a screen shows, from the table the API's suite reads too.
///
/// SPEC-097, Square's model. A screen is a **Prep station** or an **Expo
/// station**; a prep screen switches on the *kitchen routing categories* it
/// shows. Nothing is pinned to anything.
///
/// The display rule exists twice — here, and in Python where the API writes an
/// online order's ticket — and cannot be shared as code. Two copies of a rule
/// drift, and the way this one drifts is silent: a line that reaches no screen
/// is simply never cooked and nothing errors. So neither copy owns it:
/// `API/tests/fixtures/kitchen_routing_cases.json` does.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/models/screen_role.dart';

File get _casesFile =>
    File('../API/tests/fixtures/kitchen_routing_cases.json');

void main() {
  final skip =
      _casesFile.existsSync() ? null : 'POS/API is not checked out beside KDS';

  group('the shared display rule', () {
    test('the table is there and populated', () {
      // A fixture that silently fails to load makes every case vacuous — the
      // exact failure this file exists to prevent.
      final table =
          jsonDecode(_casesFile.readAsStringSync()) as Map<String, dynamic>;
      expect((table['display_cases'] as List).length, greaterThanOrEqualTo(7));
    }, skip: skip);

    test('every case answers the same here as it does in the API', () {
      final table =
          jsonDecode(_casesFile.readAsStringSync()) as Map<String, dynamic>;
      for (final raw in table['display_cases'] as List) {
        final c = (raw as Map).cast<String, dynamic>();
        final shown = screenShowsLine(
          lineRoutingCategoryIds:
              (c['line_categories'] as List).cast<String>().toList(),
          screenRoutingCategoryIds:
              (c['screen_categories'] as List).cast<String>().toList(),
          isExpo: c['is_expo'] as bool,
        );
        expect(shown, c['shown'],
            reason: '${c['name']} — ${c['why'] ?? c['name']}');
      }
    }, skip: skip);
  });

  group('the stored role', () {
    test('reads back as the role it names', () {
      expect(KdsScreenRole.fromWire('expo'), KdsScreenRole.expo);
      expect(KdsScreenRole.fromWire('prep'), KdsScreenRole.prep);
    });

    test('is prep when it says nothing', () {
      // Every screen registered before this field existed is one somebody set
      // up to show part of the kitchen. Reading those as expo would widen a
      // grill board to the whole menu overnight.
      for (final absent in [null, '', 'EXPO', 'expediter', 'nonsense']) {
        expect(KdsScreenRole.fromWire(absent), KdsScreenRole.prep,
            reason: '$absent was not read as prep');
      }
    });
  });
}
