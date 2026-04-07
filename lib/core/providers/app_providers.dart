import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_init_service.dart';

/// The Pro Firestore instance, available only after successful login.
/// Throws if accessed before Firebase is initialised.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final fs = FirebaseInitService().firestore;
  if (fs == null) throw StateError('Firestore not yet initialised');
  return fs;
});

/// SharedPreferences — loaded once, kept alive.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);
