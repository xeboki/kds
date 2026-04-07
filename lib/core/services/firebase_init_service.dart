import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/firebase_config.dart';

/// Manages the Pro Firebase connection for the KDS.
///
/// Firebase config is NOT hardcoded — it is received from the POS API
/// login response and used to initialise a secondary Firebase app at runtime.
/// This keeps subscriber Firebase credentials out of the app bundle entirely.
class FirebaseInitService {
  static final FirebaseInitService _instance = FirebaseInitService._internal();
  factory FirebaseInitService() => _instance;
  FirebaseInitService._internal();

  FirebaseApp? _proApp;
  FirebaseAuth? _proAuth;
  FirebaseFirestore? _proFirestore;
  User? _currentUser;

  FirebaseApp? get proApp => _proApp;
  FirebaseAuth? get auth => _proAuth;
  FirebaseFirestore? get firestore => _proFirestore;
  User? get currentUser => _currentUser;
  bool get isInitialized => _proApp != null && _currentUser != null;

  /// Called after a successful POS API `/login`.
  ///
  /// [config] — Pro Firebase options from the login response.
  /// [customToken] — Firebase custom auth token from the login response.
  Future<void> initializeFromAuthResponse({
    required FirebaseConfig config,
    required String customToken,
  }) async {
    try {
      if (_proApp != null) {
        debugPrint('KDS FirebaseInitService: cleaning up previous session');
        await cleanup();
      }

      _proApp = await Firebase.initializeApp(
        name: 'kds_pro',
        options: FirebaseOptions(
          apiKey: config.apiKey,
          appId: config.appId,
          messagingSenderId: config.messagingSenderId,
          projectId: config.projectId,
          storageBucket: config.storageBucket,
          authDomain: config.authDomain ?? '${config.projectId}.firebaseapp.com',
          databaseURL: config.databaseUrl,
          measurementId: config.measurementId,
        ),
      );

      _proAuth = FirebaseAuth.instanceFor(app: _proApp!);
      _proFirestore = FirebaseFirestore.instanceFor(app: _proApp!);
      _proFirestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      final cred = await _proAuth!.signInWithCustomToken(customToken);
      _currentUser = cred.user;

      debugPrint('KDS FirebaseInitService: initialized — uid=${_currentUser?.uid}');
    } catch (e) {
      debugPrint('KDS FirebaseInitService: initialization failed — $e');
      await cleanup();
      rethrow;
    }
  }

  Future<void> cleanup() async {
    try {
      await _proAuth?.signOut();
    } catch (_) {}
    _proAuth = null;
    _proFirestore = null;
    _currentUser = null;
    try {
      await _proApp?.delete();
    } catch (_) {}
    _proApp = null;
  }
}
