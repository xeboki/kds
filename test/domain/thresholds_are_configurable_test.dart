/// A kitchen sets its own idea of late, and the board honours it.
///
/// The Kitchen Display turned a ticket amber at 8 minutes and red at 15 — as
/// constants, for every restaurant using the product. That is the one number
/// on the screen a cook acts on, and it was the one nobody could change. A
/// pizza counter and a dining room do not agree about late.
///
/// The settings live on the screen record beside its role and its routing
/// categories, because the pass and the grill watch the same order with
/// different patience.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/auth/data/auth_repository.dart';
import 'package:xeboki_kds/core/models/firebase_config.dart';
import 'package:xeboki_kds/features/auth/domain/models/kds_session.dart';
import 'package:xeboki_kds/features/kds/domain/models/screen_role.dart';

KdsSession _session({int? amber, int? red}) => KdsSession(
      jwtToken: 'j',
      firebaseToken: 'f',
      firebaseConfig: const FirebaseConfig(
        apiKey: 'k', appId: 'a', projectId: 'p', messagingSenderId: 'm',
      ),
      locationId: 'loc',
      locationName: 'Kitchen',
      staffName: 'Rizwan',
      staffId: 's1',
      urgentThresholdMins: amber ?? 8,
      veryUrgentThresholdMins: red ?? 15,
    );

void main() {
  group('reading a stored value', () {
    test('a sensible number is kept', () {
      expect(minutesOrDefault(5, 8), 5);
      expect(minutesOrDefault('12', 8), 12);
      expect(minutesOrDefault(12.0, 8), 12);
    });

    test('anything unusable falls back', () {
      // Zero paints every ticket red the instant it lands; a negative is a
      // colour nothing reaches. Both are worse than the default, and either
      // can be in a document after a hand edit.
      for (final bad in <dynamic>[null, 0, -1, '', 'soon', [], {}]) {
        expect(minutesOrDefault(bad, 8), 8, reason: 'for $bad');
      }
    });

    test('amber and red keep their own defaults', () {
      expect(minutesOrDefault(null, 8), 8);
      expect(minutesOrDefault(null, 15), 15);
    });
  });

  group('the session', () {
    test('defaults to what the board used to hardcode', () {
      final s = _session();
      expect(s.urgentThresholdMins, 8);
      expect(s.veryUrgentThresholdMins, 15);
    });

    test('carries what the screen was configured with', () {
      final s = _session(amber: 4, red: 9);
      expect(s.urgentThresholdMins, 4);
      expect(s.veryUrgentThresholdMins, 9);
    });

    test('copyWith does not quietly reset them', () {
      // The fault this file exists to prevent: a copyWith that omits a field
      // resets it to the constructor default, so a kitchen that set its own
      // thresholds returns to 8 and 15 the next time anything else changes.
      final s = _session(amber: 4, red: 9)
          .copyWith(role: KdsScreenRole.expo);
      expect(s.urgentThresholdMins, 4);
      expect(s.veryUrgentThresholdMins, 9);
      expect(s.role, KdsScreenRole.expo);
    });
  });
}
