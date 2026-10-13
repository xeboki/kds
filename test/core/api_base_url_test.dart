/// A release build must reach the live API.
///
/// SPEC-097. `AppConfig.apiUrl` was a flat
/// `String.fromEnvironment(..., defaultValue: 'http://localhost:8002')`, so
/// the ordinary `flutter build web --release` shipped a kitchen tablet that
/// called localhost. It is invisible until a human presses Sign In and gets
/// `ClientException: Failed to fetch` — which reads as a network fault, not
/// as a build that was never pointed at anything.
///
/// The project's standing rule is that the API is always the live one; a
/// local or mock API is never a valid target for a shipped build.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/core/config/app_config.dart';

void main() {
  group('the API base URL', () {
    test('is the live host unless this is a debug build', () {
      // These tests run in debug, so the branch under test is the source,
      // not the value. Assert the value we CAN see, then the shape.
      expect(AppConfig.apiUrl, isNotEmpty);
      if (!kDebugMode) {
        expect(AppConfig.apiUrl, startsWith('https://'),
            reason: 'a release build is reaching a plaintext host');
      }
    });

    test('has a release branch at all, and it is not local', () {
      final source =
          File('lib/core/config/app_config.dart').readAsStringSync();

      expect(source, contains('kDebugMode'),
          reason: 'the base URL has no debug/release split, so whatever the '
              'default is ships to every kitchen');

      // The release side of the ternary is the LAST quoted literal before
      // the `;`. Splitting the ternary on `:` does not work — `http://` has
      // one, and a guard that reads `//localhost:8002' : 'https://…'` as the
      // release branch fails on a correct file and would pass on some wrong
      // ones.
      final stmt = RegExp(r'kDebugMode[^;]*;', dotAll: true).firstMatch(source);
      expect(stmt, isNotNull,
          reason: 'could not read the release branch of the base URL');
      final literals =
          RegExp(r"'([^']*)'").allMatches(stmt!.group(0)!).toList();
      expect(literals, isNotEmpty,
          reason: 'the base URL ternary names no host at all');
      final release = literals.last.group(1)!;
      expect(release, contains('xeboki.com'),
          reason: 'the release build points at $release, not the live API');
      for (final local in ['localhost', '127.0.0.1', '0.0.0.0', '192.168.']) {
        expect(release, isNot(contains(local)),
            reason: 'the release build points at a local address: $release');
      }
    });

    test('an explicit --dart-define still wins', () {
      // Without this, a deliberate point-at-my-laptop during development
      // would be silently ignored, and the next person would edit the
      // default back to localhost to get their work done.
      final source =
          File('lib/core/config/app_config.dart').readAsStringSync();
      expect(source, contains("String.fromEnvironment('XEBOKI_API_URL'"));
      expect(source, contains('envUrl.isNotEmpty'),
          reason: 'the define is read but never preferred');
    });
  });
}
