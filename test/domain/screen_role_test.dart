/// What a screen is for, and what that means for its board.
///
/// SPEC-097. `expo` used to be a station *type* only — one more kind of
/// station beside grill and fryer. Square and Toast both make it a property of
/// the device, because the two are different questions: a station is a place
/// in the kitchen, a role belongs to the tablet on the wall. The pass is both
/// a station food is routed to AND the screen that assembles the order, and a
/// station type alone cannot say that.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/auth/domain/models/kds_session.dart';
import 'package:xeboki_kds/features/kds/domain/models/screen_role.dart';
import 'package:xeboki_kds/core/models/firebase_config.dart';

KdsSession _session({String? stationId, KdsScreenRole? role}) => KdsSession(
      jwtToken: 'j',
      firebaseToken: 'f',
      firebaseConfig: const FirebaseConfig(
          apiKey: '', appId: '', messagingSenderId: '', projectId: ''),
      locationId: 'loc',
      locationName: 'Loc',
      staffName: 'S',
      staffId: '1',
      stationId: stationId,
      role: role ?? KdsScreenRole.prep,
    );

void main() {
  group('the stored value', () {
    test('reads back as the role it names', () {
      expect(KdsScreenRole.fromWire('expo'), KdsScreenRole.expo);
      expect(KdsScreenRole.fromWire('prep'), KdsScreenRole.prep);
    });

    test('is prep when it says nothing', () {
      // Every screen registered before this field existed is one somebody
      // pinned to a station. Reading those as expo would widen a grill board
      // to the whole menu overnight.
      for (final absent in [null, '', 'EXPO', 'expediter', 'nonsense']) {
        expect(KdsScreenRole.fromWire(absent), KdsScreenRole.prep,
            reason: '$absent was not read as prep');
      }
    });
  });

  group('what the board filters by', () {
    test('a prep screen filters by its station', () {
      expect(stationFilterFor(KdsScreenRole.prep, 'st_grill'), 'st_grill');
    });

    test('an expo screen filters by nothing, even when pinned', () {
      // The pass is a real station that food is routed to. An expediter
      // standing at it still has to see the grill's lines, or it cannot tell
      // when the order is complete.
      expect(stationFilterFor(KdsScreenRole.expo, 'st_pass'), isNull);
    });

    test('an unpinned prep screen filters by nothing', () {
      for (final pin in [null, '']) {
        expect(stationFilterFor(KdsScreenRole.prep, pin), isNull);
      }
    });
  });

  group('the session', () {
    test('exposes the rule rather than the raw pin', () {
      expect(_session(stationId: 'st_pass', role: KdsScreenRole.expo)
          .boardStationId, isNull);
      expect(_session(stationId: 'st_grill').boardStationId, 'st_grill');
    });

    test('keeps its role when a station is picked', () {
      // A copyWith that omits a field resets it to the constructor default,
      // which here would quietly turn every expo screen into a prep screen
      // the moment somebody chose a station.
      final expo = _session(role: KdsScreenRole.expo);
      expect(expo.copyWith(stationId: 'st_pass').role, KdsScreenRole.expo);
      expect(expo.copyWith(stationId: 'st_pass').boardStationId, isNull);
    });
  });
}
