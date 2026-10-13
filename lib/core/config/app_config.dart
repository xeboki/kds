import 'package:flutter/foundation.dart';

/// Build-time configuration injected via --dart-define.
///
/// Only the API URL is required at build time.
/// Firebase config is received dynamically from the POS API login response —
/// the merchant never configures Firebase credentials directly.
///
/// flutter run \
///   --dart-define=XEBOKI_API_URL=http://192.168.1.100:8002
class AppConfig {
  AppConfig._();

  /// POS API base URL.
  ///
  /// The shape is the till's (`Pro/lib/constants/api_constants.dart`): an
  /// explicit define wins, otherwise debug reaches a local API and **release
  /// reaches the live one**.
  ///
  /// SPEC-097. This used to be a flat `defaultValue: 'http://localhost:8002'`
  /// with no release branch, so `flutter build web --release` — the ordinary
  /// way to ship this app — produced a kitchen tablet that called a machine
  /// that is not there. It fails at the login button with
  /// `ClientException: Failed to fetch`, which reads like a network fault
  /// rather than a build that was never pointed anywhere.
  static String get apiUrl {
    const envUrl = String.fromEnvironment('XEBOKI_API_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    return kDebugMode ? 'http://localhost:8002' : 'https://api.pos.xeboki.com';
  }

  static const bool isProduction = String.fromEnvironment(
        'XEBOKI_ENV',
        defaultValue: 'development',
      ) ==
      'production';
}
