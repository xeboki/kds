/// A `\$` in a Dart string is a literal dollar, not an interpolation.
///
/// SPEC-097. `.map((e) => '\$e')` turned every kitchen routing category id
/// into the literal string `$e`. The screen was then switched on for a
/// category called `$e`, which matches nothing — so a correctly registered,
/// correctly configured Grill screen behaved exactly like one with nothing
/// switched on, and showed only unclaimed work.
///
/// Nothing catches this: it compiles, it analyses clean, the list is the right
/// length and full of plausible strings, and the only symptom is a board that
/// is quieter than it should be. It took reading the device's own stored
/// session to see `["$e"]`.
///
/// Guarded across the whole app because the cause is mechanical — an escaped
/// dollar inside a single-quoted string is almost never deliberate, and when
/// it is, it is not in a `.map` building ids.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nothing builds a string from an escaped interpolation', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart') ||
          entity.path.endsWith('.freezed.dart')) {
        continue;
      }

      final lines = entity.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        // `'\$name'` or `'\${…}'` — an escaped dollar immediately followed by
        // something that was meant to be interpolated.
        if (RegExp(r"'[^']*\\\$[A-Za-z_{][^']*'").hasMatch(line)) {
          offenders.add('${entity.path}:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'these produce the literal text rather than the value, which '
            'compiles, analyses clean, and yields a plausible list of wrong '
            'strings:\n  ${offenders.join('\n  ')}');
  });
}
