/// Everything the kitchen can do has a way to do it.
///
/// SPEC-097 097-A. This app's repository has carried `recallOrder`,
/// `set86Item` and `getBumpedOrders` since it was written, and **nothing
/// called them**. A bumped ticket could not be brought back — from a board
/// whose bump button is a single tap with no confirmation — and an item could
/// not be 86'd, though the tile had always rendered an 86'd line perfectly.
///
/// That is the same shape as the back office's unauthored `category_ids`: the
/// capability exists, the screen looks complete, and the feature does not
/// work. Nothing errors, so only somebody trying to do the thing finds out.
///
/// Derived from the repository interface rather than a list, so a capability
/// added later is covered the day it is added.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Capabilities that deliberately have no button.
///
/// Each needs a reason, so this cannot quietly become the place unreachable
/// features go to be forgotten.
const _notUserFacing = <String, String>{
  'watchOrders': 'the board itself',
  'getStations': 'stations are configured in the back office now',
  'updateStation': 'stations are configured in the back office now',
  'updateItemStatus': 'reached through markItemStarted / markItemCompleted',
  'updateOrderStatus': 'reached through bumpOrder and the item statuses',
};

void main() {
  test('every repository capability is reachable from the UI', () {
    final interface =
        File('lib/features/kds/domain/repositories/kitchen_repository.dart')
            .readAsStringSync();

    final methods = RegExp(r'Future<[^>]*>\s+(\w+)\s*\(')
        .allMatches(interface)
        .map((m) => m.group(1)!)
        .toSet();
    expect(methods.length, greaterThan(8),
        reason: 'parsed almost no methods — the regex has broken and this '
            'guard would vouch for everything');

    final ui = Directory('lib/features/kds/presentation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync())
        .join('\n');

    final unreachable = <String>[];
    for (final method in methods) {
      if (_notUserFacing.containsKey(method)) continue;
      if (!ui.contains('$method(')) unreachable.add(method);
    }

    expect(unreachable, isEmpty,
        reason: 'the kitchen cannot actually do these — the capability is '
            'there, the screen looks complete, and nothing errors:\n  '
            '${unreachable.join('\n  ')}');
  });

  test('the exemptions are all still real methods', () {
    // An exemption for a method that no longer exists is an excuse outliving
    // its reason, and would hide the next genuinely unreachable one.
    final interface =
        File('lib/features/kds/domain/repositories/kitchen_repository.dart')
            .readAsStringSync();
    final stale = _notUserFacing.keys
        .where((m) => !interface.contains('$m('))
        .toList();
    expect(stale, isEmpty,
        reason: 'these are exempted but no longer exist: ${stale.join(', ')}');
  });
}
