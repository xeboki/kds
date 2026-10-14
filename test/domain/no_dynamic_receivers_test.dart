/// Nothing in the UI holds a model as `dynamic`.
///
/// SPEC-097. `_buildAppBar` took `dynamic session` and read
/// `session.stationId` after that field had been removed from `KdsSession`.
/// The analyzer cannot see a missing member on a `dynamic` receiver, so:
///
///   * `flutter analyze lib test` reported **no issues**;
///   * every test passed;
///   * the board threw `NoSuchMethodError: method not found: 'stationId'` on
///     build and rendered a blank grey screen, on every frame.
///
/// A release build minifies the name out of the message too, so the only way
/// to read it was to rebuild in profile mode. Typing the parameter turns all
/// of that back into a compile error, which is where it belongs.
///
/// `Map<String, dynamic>` is fine and everywhere — that is JSON, not a
/// receiver somebody calls members on.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no field or parameter in the KDS UI is typed dynamic', () {
    final offenders = <String>[];
    final dir = Directory('lib/features/kds/presentation');

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        // `dynamic` as a type, not inside `Map<String, dynamic>` or a cast.
        if (RegExp(r'(?<![<,]\s{0,4})\bdynamic\s+[a-z_]\w*\s*[;,)=]')
            .hasMatch(line.replaceAll('Map<String, dynamic>', 'JSON'))) {
          offenders.add('${entity.path}:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'the analyzer cannot see a missing member on a dynamic '
            'receiver, so these turn a compile error into a blank screen at '
            'runtime:\n  ${offenders.join('\n  ')}');
  });
}
