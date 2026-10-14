/// The device loads its own screen record.
///
/// SPEC-097. Registration existed in the back office — Quick Code, pending
/// approval, Prep/Expo, routing categories — and the device had no identity at
/// all. It signed in as a staff member, so it could not know which screen it
/// was: everything chosen in the back office reached nothing, and a prep
/// screen showed only unclaimed work, which looks like a quiet kitchen rather
/// than a screen nobody has told what to show.
///
/// `kds_screens` lives in Manager Firebase and this app only ever signs into
/// the tenant's, so the config cannot be read directly — it comes from
/// `GET /kds/screen/{id}` with the login token.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo =
      File('lib/features/auth/data/auth_repository.dart').readAsStringSync();
  final client =
      File('lib/core/services/api_client.dart').readAsStringSync();

  group('registration', () {
    test('the device claims a code the way a till does', () {
      expect(client, contains('/auth/register-with-code'),
          reason: 'nothing registers this device');
      expect(client, contains("'device_type': 'kds'"),
          reason: 'the device does not say what kind it is');
      expect(client, contains('/auth/registration-status/'),
          reason: 'nothing waits for approval, so the screen would never '
              'learn it had been approved');
    });

    test('the screen id outlives the session', () {
      // A screen stays the same screen across staff logins — that is the
      // point of registering the device rather than the person.
      expect(repo, contains("_kScreenIdKey"),
          reason: 'the screen id is not stored separately from the session');
      expect(repo, contains('saveRegisteredScreenId'));
      expect(repo, contains('registeredScreenId'));
    });
  });

  group('its configuration', () {
    test('is loaded on login and on restore', () {
      // Once each, or a screen re-pointed in the back office would keep
      // showing the old thing until somebody signed out.
      final applies = RegExp(r'_applyScreenConfig\(').allMatches(repo).length;
      expect(applies, greaterThanOrEqualTo(3),
          reason: 'the config is not applied on both login and restore '
              '(found $applies references including the declaration)');
    });

    test('comes from the API, not from a database this app cannot read', () {
      expect(client, contains('/kds/screen/'),
          reason: 'the screen config is not fetched from the API — and '
              '`kds_screens` is in Manager Firebase, which this app never '
              'signs into');
    });

    test('a failure to load leaves the kitchen working', () {
      final body = repo.substring(repo.indexOf('_applyScreenConfig'));
      expect(body.contains('catch'), isTrue,
          reason: 'a config read that fails would stop a kitchen screen '
              'working entirely');
    });

    test('an unregistered device is left alone rather than guessed at', () {
      final body = repo.substring(repo.indexOf('Future<KdsSession> _applyScreenConfig'));
      expect(body, contains('if (screenId == null) return session;'),
          reason: 'an unregistered screen should keep working as it did, not '
              'be given somebody else\'s configuration');
    });
  });
}
