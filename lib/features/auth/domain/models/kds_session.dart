import '../../../../core/models/firebase_config.dart';
import '../../../kds/domain/models/screen_role.dart';

/// Represents an authenticated KDS session.
/// Produced by the POS API /login response and persisted to SharedPreferences
/// so the KDS does not require staff to re-login on every app restart.
class KdsSession {
  final String jwtToken;
  final String firebaseToken;
  final FirebaseConfig firebaseConfig;
  final String locationId;
  final String locationName;

  /// Optional station this KDS is pinned to (null = show all stations).
  final String? stationId;

  /// What this screen is for — prep or expo.
  ///
  /// SPEC-097. Set on the screen's registered record in the back office, not
  /// chosen on the device: it is a property of the tablet on the wall, the
  /// way Square and Toast treat it, so replacing the hardware keeps the role.
  final KdsScreenRole role;

  /// The station this board filters by, which is [stationId] for a prep
  /// screen and nothing at all for an expo screen — an expediter has to see
  /// every station's lines to know when the order is complete.
  String? get boardStationId => stationFilterFor(role, stationId);

  /// Display name of the logged-in staff member.
  final String staffName;
  final String staffId;

  /// Subscription plan name (e.g. "Free Forever", "Starter", "Pro").
  final String subscriptionPlan;

  /// Subscription status (e.g. "active", "trialing", "cancelled").
  final String subscriptionStatus;

  /// Returns true when the merchant cannot use the KDS (free plan or inactive).
  bool get isSubscriptionBlocked {
    final isFree = subscriptionPlan.toLowerCase().contains('free');
    final isInactive = subscriptionStatus != 'active' && subscriptionStatus != 'trialing';
    return isFree || isInactive;
  }

  const KdsSession({
    required this.jwtToken,
    required this.firebaseToken,
    required this.firebaseConfig,
    required this.locationId,
    required this.locationName,
    required this.staffName,
    required this.staffId,
    this.stationId,
    this.role = KdsScreenRole.prep,
    this.subscriptionPlan = '',
    this.subscriptionStatus = '',
  });

  factory KdsSession.fromLoginResponse(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final rawConfig = (json['pro_firebase_config'] ??
        json['firebase_config']) as Map<String, dynamic>;

    // Use first location from the response
    final locations = json['locations'] as List<dynamic>? ?? [];
    final firstLoc = locations.isNotEmpty
        ? locations.first as Map<String, dynamic>
        : <String, dynamic>{};

    return KdsSession(
      jwtToken: json['jwt_token'] as String,
      firebaseToken: json['firebase_token'] as String,
      firebaseConfig: FirebaseConfig.fromJson(rawConfig),
      locationId: firstLoc['id'] as String? ?? '',
      locationName: firstLoc['name'] as String? ?? '',
      staffName: user['full_name'] as String? ?? user['name'] as String? ?? '',
      staffId: (user['staff_id'] ?? user['id']).toString(),
      subscriptionPlan: json['subscription_plan'] as String? ?? '',
      subscriptionStatus: json['subscription_status'] as String? ?? '',
      role: KdsScreenRole.fromWire(json['screen_role'] as String?),
    );
  }

  KdsSession copyWith({
    String? stationId,
    String? locationId,
    String? locationName,
    KdsScreenRole? role,
  }) {
    return KdsSession(
      jwtToken: jwtToken,
      firebaseToken: firebaseToken,
      firebaseConfig: firebaseConfig,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      staffName: staffName,
      staffId: staffId,
      stationId: stationId ?? this.stationId,
      // Carried explicitly. A copyWith that omits a field resets it to the
      // constructor default, which here would silently turn every expo
      // screen into a prep screen the next time somebody picked a station.
      role: role ?? this.role,
      subscriptionPlan: subscriptionPlan,
      subscriptionStatus: subscriptionStatus,
    );
  }
}
