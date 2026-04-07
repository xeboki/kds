import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/firebase_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/firebase_init_service.dart';
import '../domain/models/kds_session.dart';

const _kSessionKey = 'kds_session_v1';

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
    final session = KdsSession.fromLoginResponse(body);
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
      final session = _sessionFromMap(map);
      await FirebaseInitService().initializeFromAuthResponse(
        config: session.firebaseConfig,
        customToken: session.firebaseToken,
      );
      return session;
    } catch (_) {
      return null;
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
        'station_id': s.stationId,
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
      stationId: m['station_id'] as String?,
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
