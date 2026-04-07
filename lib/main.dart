import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape — kitchen tablets are always horizontal
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // The DEFAULT Firebase app must be initialised before any Firebase calls.
  // For the KDS there is no google-services.json — the subscriber's Pro Firebase
  // is initialised dynamically AFTER login via FirebaseInitService, using the
  // config returned by the POS API. This placeholder satisfies the SDK init
  // requirement only; it is never used for actual reads/writes.
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'kds-placeholder',
        appId: 'kds-placeholder',
        messagingSenderId: '000000000000',
        projectId: 'kds-placeholder',
      ),
    );
  } catch (_) {
    // Swallow duplicate-app error on hot-restart
  }

  runApp(const ProviderScope(child: KdsApp()));
}

class KdsApp extends ConsumerWidget {
  const KdsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Restore persisted session on cold start (fire-and-forget)
    ref.watch(_sessionRestoreProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Xeboki KDS',
      debugShowCheckedModeBanner: false,
      theme: KdsTheme.dark,
      routerConfig: router,
    );
  }
}

/// Fires once on app start to restore a previously saved session from
/// SharedPreferences, avoiding staff needing to log in on every tablet restart.
final _sessionRestoreProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.read(sessionProvider.notifier).restore();
});
