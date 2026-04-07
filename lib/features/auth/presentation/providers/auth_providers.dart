import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/kds_session.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

// ── Session state ─────────────────────────────────────────────────────────────

/// Holds the active [KdsSession], or null when not authenticated.
/// keepAlive = true so the session is never discarded on navigation.
final sessionProvider = StateNotifierProvider<SessionNotifier, KdsSession?>(
  (ref) => SessionNotifier(ref.read(authRepositoryProvider)),
);

class SessionNotifier extends StateNotifier<KdsSession?> {
  SessionNotifier(this._repo) : super(null);

  final AuthRepository _repo;

  /// Attempt to restore a persisted session on cold start.
  Future<bool> restore() async {
    final session = await _repo.restoreSession();
    state = session;
    return session != null;
  }

  /// Login with staff credentials.
  Future<void> login({required String email, required String password}) async {
    final session = await _repo.login(email: email, password: password);
    state = session;
  }

  /// Update the pinned station for this terminal (persisted separately).
  void setStation(String? stationId) {
    if (state == null) return;
    state = state!.copyWith(stationId: stationId);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = null;
  }
}

// ── Auth loading state ────────────────────────────────────────────────────────

enum AuthStatus { loading, authenticated, unauthenticated }

final authStatusProvider = Provider<AuthStatus>((ref) {
  final session = ref.watch(sessionProvider);
  return session != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
});
