/// Every field this app queries is a field something actually writes.
///
/// The Kitchen Display could not read a ticket. `build.yaml` did not exist, so
/// `json_serializable` defaulted to camelCase and the generated models parsed
/// `locationId`, `orderTime`, `isActive`; the repository queried the same.
/// Every writer stores snake_case — the till (`Pro/build.yaml` has had
/// `field_rename: snake` since the beginning), the API when an online order is
/// paid, and Manager when a station is saved.
///
/// **A Firestore `.where()` on a field that does not exist is not an error.**
/// It is an empty list, which this app renders as "No Active Orders" — the
/// same thing a quiet kitchen looks like. It would have looked identical on
/// the day it started working, which is why this is a test and not a comment.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The shape on the wire, read from the **till's** generated serialiser.
///
/// Read rather than listed: a copy of the field names here would drift from
/// the thing it describes, which is the whole fault being guarded against.
Set<String> _storedFields() {
  final pro = File('../Pro/lib/features/restaurant/domain/models/'
      'kitchen_order.g.dart');
  if (!pro.existsSync()) return {};
  return RegExp(r"^\s+'([a-z_]+)':", multiLine: true)
      .allMatches(pro.readAsStringSync())
      .map((m) => m.group(1)!)
      .toSet();
}

/// Every Firestore field this app filters or sorts by.
///
/// Only `.where('…')` with a **string literal** — the Dart `Iterable.where`
/// that appears in the same file takes a closure and must not be swept up.
Set<String> _queriedFields() {
  final repo = File('lib/features/kds/data/repositories/'
          'kitchen_repository_firestore.dart')
      .readAsStringSync();
  return RegExp(r"\.(?:where|orderBy)\('([a-zA-Z_]+)'")
      .allMatches(repo)
      .map((m) => m.group(1)!)
      .toSet();
}

void main() {
  final stored = _storedFields();
  final skip = stored.isEmpty ? 'POS/Pro is not checked out beside KDS' : null;

  group('the board queries fields that exist', () {
    test('the sweep reads both sides', () {
      // A sweep that matches nothing passes everything under it — and this
      // app has already shipped a year of queries that matched nothing.
      expect(stored.length, greaterThan(15),
          reason: 'read only ${stored.length} stored fields out of the till, '
              'so every assertion below is vacuous');
      expect(_queriedFields(), isNotEmpty,
          reason: 'found no queries at all, so the regex has stopped matching');
    }, skip: skip);

    test('every queried field is one the till writes', () {
      final missing = _queriedFields().difference(stored).toList()..sort();
      expect(missing, isEmpty,
          reason: 'these are filtered or sorted on and nothing writes them, '
              'so the board matches nothing and renders as an empty kitchen: '
              '${missing.join(', ')}');
    }, skip: skip);

    test('nothing queries camelCase', () {
      // The specific shape of the original fault, named so a reviewer who
      // has not read the history still understands the failure.
      final camel = _queriedFields()
          .where((f) => f.contains(RegExp('[A-Z]')))
          .toList()
        ..sort();
      expect(camel, isEmpty,
          reason: 'the collections are snake_case on the wire; these would '
              'match nothing and raise no error: ${camel.join(', ')}');
    });
  });

  group('the generator is configured', () {
    test('build.yaml exists and renames to snake', () {
      final build = File('build.yaml');
      expect(build.existsSync(), isTrue,
          reason: 'without build.yaml json_serializable defaults to '
              'camelCase, which is how this app came to read nothing');
      expect(build.readAsStringSync(), contains('field_rename: snake'));
    });

    test('the generated model parses snake_case', () {
      // The generator actually ran — a build.yaml nobody has rebuilt against
      // is a config file, not a behaviour.
      final g = File('lib/features/kds/domain/models/kitchen_order.g.dart')
          .readAsStringSync();
      expect(g, contains("'location_id'"));
      expect(g, isNot(contains("\$checkedConvert('locationId'")),
          reason: 'the models still parse camelCase — run build_runner');
    });
  });
}
