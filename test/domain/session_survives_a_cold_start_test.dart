/// Everything the back office configured survives being written down.
///
/// The session is persisted as a map and rebuilt from it on every cold start.
/// A field added to the model but not to that map comes back as its
/// constructor default, silently: the thresholds a kitchen set reverted to 8
/// and 15 the next time the tablet was switched on, and nothing anywhere said
/// so.
///
/// This walks the map rather than listing fields, so the next field added to
/// the session has to be carried too or this fails.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every configured field is written down and read back', () {
    final source =
        File('lib/features/auth/data/auth_repository.dart').readAsStringSync();

    // The *definitions*, not the call sites. `_sessionFromMap` is called
    // before it is declared, so searching for the bare name finds the call and
    // a window from there reads the wrong function entirely — which is how the
    // first version of this test reported every field missing.
    String body(String signature) {
      final start = source.indexOf(signature);
      expect(start, greaterThan(-1), reason: 'could not find $signature');
      // To the end of the function, by matching braces rather than guessing a
      // length: a fixed window either stops short or runs into the next one.
      var depth = 0;
      var started = false;
      for (var i = start; i < source.length; i++) {
        if (source[i] == '{') {
          depth++;
          started = true;
        } else if (source[i] == '}') {
          depth--;
          if (started && depth == 0) return source.substring(start, i);
        }
      }
      fail('unbalanced braces after $signature');
    }

    final written = body('Map<String, dynamic> _sessionToMap(');
    final read = body('KdsSession _sessionFromMap(');

    // Configuration that comes from the screen's record — the fields that are
    // not derived from the login response and so cannot be recovered without
    // being stored.
    const configured = [
      'screen_role',
      'routing_category_ids',
      'urgent_threshold_mins',
      'very_urgent_threshold_mins',
    ];

    final missing = <String>[];
    for (final key in configured) {
      if (!written.contains("'$key'")) missing.add('$key: never stored');
      if (!read.contains("'$key'")) missing.add('$key: never read back');
    }

    expect(missing, isEmpty,
        reason: 'these are lost on a cold start:\n  ${missing.join('\n  ')}');
  });
}
