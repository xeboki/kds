/// Every board filter goes through the role rule.
///
/// SPEC-097. `stationFilterFor` and `boardStationId` are covered by unit
/// tests, and that is not enough: pointing the orders query back at
/// `session.stationId` left every one of those tests green while an expo
/// screen silently went back to seeing only the pass's own lines.
///
/// This is the second time in this app that a correct helper nothing calls
/// has passed a full suite, so the call sites are held here directly.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Where the raw pin is legitimately read: the session defines it, and the
/// header and the station picker display and set it. Everywhere else, reading
/// it to filter a board is the bug.
const _mayReadTheRawPin = [
  'lib/features/auth/domain/models/kds_session.dart',
  'lib/features/auth/data/auth_repository.dart',
  'lib/features/auth/presentation/providers/auth_providers.dart',
];

void main() {
  test('nothing filters a board by the raw pin', () {
    final offenders = <String>[];

    // `stationId: <anything>.stationId` — passing the raw pin as the thing a
    // query or a view filters by.
    final passingTheRawPin =
        RegExp(r'stationId:\s*session\??\.stationId');

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (_mayReadTheRawPin.any(path.endsWith)) continue;
      final source = entity.readAsStringSync();
      for (final line in source.split('\n').asMap().entries) {
        if (passingTheRawPin.hasMatch(line.value)) {
          offenders.add('$path:${line.key + 1}: ${line.value.trim()}');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'these filter by the pinned station instead of the role rule, '
            'so an expo screen sees only its own station and cannot tell when '
            'an order is complete — use `session.boardStationId`:\n  '
            '${offenders.join('\n  ')}');
  });

  test('the rule is actually reached from the board', () {
    // The mirror of the test above: it is possible to satisfy "nothing uses
    // the raw pin" by using nothing at all.
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    expect(sources.contains('boardStationId'), isTrue,
        reason: 'no board asks the role rule what to filter by');
  });
}
