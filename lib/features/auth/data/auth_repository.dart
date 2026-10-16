import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/firebase_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/firebase_init_service.dart';
import '../domain/models/kds_session.dart';
import '../../kds/domain/models/screen_role.dart';

const _kSessionKey = 'kds_session_v1';

/// The id of the `kds_screens` record this device registered as.
///
/// SPEC-097. Stored separately from the session because it outlives it: a
/// screen stays the same screen across staff logins, which is the whole point
/// of registering the device rather than the person.
const _kScreenIdKey = 'kds_screen_id_v1';

/// Handles KDS authentication against the POS API.
/// After a successful login the session (JWT + Firebase config) is persisted
/// so the kitchen tablet auto-reconnects on restart without staff interaction.
class AuthRepository {
  AuthRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Login with staff credentials. Returns a fully-initialised [KdsSession].
  Future<KdsSession> login({
    required String email,
    required String password,
  }) async {
    final body = await _api.login(email: email, password: password);
    var session = KdsSession.fromLoginResponse(body);
    session = await _applyScreenConfig(session);
    await _persistSession(session);
    await FirebaseInitService().initializeFromAuthResponse(
      config: session.firebaseConfig,
      customToken: session.firebaseToken,
    );
    return session;
  }

  /// Try to restore a previously saved session (on app cold-start).
  /// Returns null if no stored session or Firebase re-init fails.
  Future<KdsSession?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSessionKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      var session = _sessionFromMap(map);
      await FirebaseInitService().initializeFromAuthResponse(
        config: session.firebaseConfig,
        customToken: session.firebaseToken,
      );
      // Re-read on every start: the back office may have changed what this
      // screen shows, or taken it offline, since it was last switched on.
      session = await _applyScreenConfig(session);
      await _persistSession(session);
      return session;
    } catch (_) {
      return null;
    }
  }

  /// The id of the screen this device is registered as, if it is.
  Future<String?> registeredScreenId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kScreenIdKey);
    return (id == null || id.isEmpty) ? null : id;
  }

  Future<void> saveRegisteredScreenId(String screenId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kScreenIdKey, screenId);
  }

  /// Fill in what this screen is set up to show.
  ///
  /// A device that has not been registered keeps the session as it is — an
  /// unregistered screen still works, it just shows everything unclaimed and
  /// nothing claimed, which is what it did before registration existed.
  ///
  /// A screen taken offline in the back office is left alone here rather than
  /// pretended about; the board surfaces the refusal.
  Future<KdsSession> _applyScreenConfig(KdsSession session) async {
    final screenId = await registeredScreenId();
    if (screenId == null) return session;
    try {
      final config = await _api.getScreenConfig(
        jwt: session.jwtToken,
        screenId: screenId,
      );
      return session.copyWith(
        role: KdsScreenRole.fromWire(config['role'] as String?),
        routingCategoryIds: ((config['routing_category_ids'] as List?) ?? const [])
            .map((e) => '$e')
            .toList(),
        urgentThresholdMins: minutesOrDefault(config['urgent_threshold_mins'], 8),
        veryUrgentThresholdMins:
            minutesOrDefault(config['very_urgent_threshold_mins'], 15),
      );
    } catch (_) {
      // A config read that fails must not stop a kitchen working. The screen
      // falls back to what it had, which errs towards showing more.
      return session;
    }
  }

  Future<void> logout() async {
    await FirebaseInitService().cleanup();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
  }

  // ── SharedPreferences helpers ────────────────────────────────────────────────

  Future<void> _persistSession(KdsSession s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionKey, jsonEncode(_sessionToMap(s)));
  }

  Map<String, dynamic> _sessionToMap(KdsSession s) => {
        'jwt_token': s.jwtToken,
        'firebase_token': s.firebaseToken,
        'firebase_config': {
          'apiKey': s.firebaseConfig.apiKey,
          'appId': s.firebaseConfig.appId,
          'projectId': s.firebaseConfig.projectId,
          'messagingSenderId': s.firebaseConfig.messagingSenderId,
          'storageBucket': s.firebaseConfig.storageBucket,
          'authDomain': s.firebaseConfig.authDomain,
          'databaseURL': s.firebaseConfig.databaseUrl,
          'measurementId': s.firebaseConfig.measurementId,
        },
        'location_id': s.locationId,
        'location_name': s.locationName,
        'staff_name': s.staffName,
        'staff_id': s.staffId,
        // Persisted, or a restart quietly demotes an expo screen to prep and
        // forgets everything it was switched on for.
        'screen_role': s.role.wire,
        'routing_category_ids': s.routingCategoryIds,
        'subscription_plan': s.subscriptionPlan,
        'subscription_status': s.subscriptionStatus,
      };

  KdsSession _sessionFromMap(Map<String, dynamic> m) {
    final cfg = m['firebase_config'] as Map<String, dynamic>;
    return KdsSession(
      jwtToken: m['jwt_token'] as String,
      firebaseToken: m['firebase_token'] as String,
      firebaseConfig: _configFromMap(cfg),
      locationId: m['location_id'] as String,
      locationName: m['location_name'] as String,
      staffName: m['staff_name'] as String,
      staffId: m['staff_id'] as String,
      role: KdsScreenRole.fromWire(m['screen_role'] as String?),
      routingCategoryIds: ((m['routing_category_ids'] as List?) ?? const [])
          .map((e) => '$e')
          .toList(),
      subscriptionPlan: m['subscription_plan'] as String? ?? '',
      subscriptionStatus: m['subscription_status'] as String? ?? '',
    );
  }

  FirebaseConfig _configFromMap(Map<String, dynamic> m) {
    return FirebaseConfig(
      apiKey: m['apiKey'] as String,
      appId: m['appId'] as String,
      projectId: m['projectId'] as String,
      messagingSenderId: m['messagingSenderId'] as String? ?? '',
      storageBucket: m['storageBucket'] as String?,
      authDomain: m['authDomain'] as String?,
      databaseUrl: m['databaseURL'] as String?,
      measurementId: m['measurementId'] as String?,
    );
  }
}

/// A minute count from the screen's configuration, or the fallback.
///
/// Mirrors `_positive_minutes` in the API and `_minutes` in the back office.
/// Zero would paint every ticket red the moment it lands and a negative is a
/// colour nothing reaches — both worse than the default, and this is the last
/// place to catch either before a cook is looking at it.
int minutesOrDefault(dynamic raw, int fallback) {
  final value = raw is num ? raw.toInt() : int.tryParse('${raw ?? ''}');
  return (value != null && value > 0) ? value : fallback;
}
