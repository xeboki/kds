import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/subscription_gate_screen.dart';
import '../features/kds/presentation/screens/kds_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _SessionChangeNotifier(ref);

  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;
      final isLogin = loc == '/login';
      final isGate = loc == '/subscription-gate';

      if (session == null) {
        // Not logged in — send to login unless already there
        return isLogin ? null : '/login';
      }

      // Logged in but subscription is blocked
      if (session.isSubscriptionBlocked) {
        return isGate ? null : '/subscription-gate';
      }

      // Logged in with valid subscription
      if (isLogin || isGate) return '/kds';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/subscription-gate',
        builder: (_, __) => const SubscriptionGateScreen(),
      ),
      GoRoute(
        path: '/kds',
        builder: (_, __) => const KitchenDisplayScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}',
            style: const TextStyle(color: Colors.white)),
      ),
    ),
  );
});

/// Bridges a Riverpod [StateNotifierProvider] to [ChangeNotifier] so that
/// GoRouter's [refreshListenable] re-evaluates redirect on session changes.
class _SessionChangeNotifier extends ChangeNotifier {
  _SessionChangeNotifier(Ref ref) {
    _sub = ref.listen<dynamic>(sessionProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
