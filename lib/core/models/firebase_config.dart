/// Firebase configuration returned by the POS API login response.
/// Used to initialise the subscriber's Pro Firebase app at runtime.
class FirebaseConfig {
  final String apiKey;
  final String appId;
  final String projectId;
  final String messagingSenderId;
  final String? storageBucket;
  final String? authDomain;
  final String? databaseUrl;
  final String? measurementId;

  const FirebaseConfig({
    required this.apiKey,
    required this.appId,
    required this.projectId,
    required this.messagingSenderId,
    this.storageBucket,
    this.authDomain,
    this.databaseUrl,
    this.measurementId,
  });

  factory FirebaseConfig.fromJson(Map<String, dynamic> json) {
    return FirebaseConfig(
      apiKey: json['apiKey'] as String? ?? json['api_key'] as String,
      appId: json['appId'] as String? ?? json['app_id'] as String,
      projectId: json['projectId'] as String? ?? json['project_id'] as String,
      messagingSenderId: json['messagingSenderId'] as String? ??
          json['messaging_sender_id'] as String? ?? '',
      storageBucket: json['storageBucket'] as String? ?? json['storage_bucket'] as String?,
      authDomain: json['authDomain'] as String? ?? json['auth_domain'] as String?,
      databaseUrl: json['databaseURL'] as String? ?? json['database_url'] as String?,
      measurementId: json['measurementId'] as String? ?? json['measurement_id'] as String?,
    );
  }
}
