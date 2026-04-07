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

  /// POS API base URL. Override per deployment.
  static const String apiUrl = String.fromEnvironment(
    'XEBOKI_API_URL',
    defaultValue: 'http://localhost:8002',
  );

  static const bool isProduction = String.fromEnvironment(
        'XEBOKI_ENV',
        defaultValue: 'development',
      ) ==
      'production';
}
