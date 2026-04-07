import 'package:freezed_annotation/freezed_annotation.dart';

part 'kitchen_order.freezed.dart';
part 'kitchen_order.g.dart';

@freezed
class KitchenOrder with _$KitchenOrder {
  const factory KitchenOrder({
    required String id,
    required String orderId,
    required String locationId,

    // Table info
    String? tableNumber,
    String? tableSectionName,
    int? guestCount,
    int? seatCount,

    // Order info
    required String orderNumber,
    required KitchenOrderType orderType,
    required KitchenOrderPriority priority,
    required KitchenOrderStatus status,

    // Items
    @Default([]) List<KitchenOrderItem> items,

    // Staff
    String? serverId,
    String? serverName,
    String? preparedBy,

    // Timing
    required DateTime orderTime,
    DateTime? startedAt,
    DateTime? readyAt,
    DateTime? servedAt,
    DateTime? bumpedAt,
    DateTime? recalledAt,
    DateTime? scheduledFor,

    // Notes
    String? specialInstructions,
    String? allergyInfo,

    // Station routing
    @Default([]) List<String> assignedStations,

    // Source
    String? sourceLabel, // 'DoorDash', 'Uber Eats', 'Online', etc.

    // Metadata
    Map<String, dynamic>? metadata,
  }) = _KitchenOrder;

  const KitchenOrder._();

  factory KitchenOrder.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderFromJson(json);

  int get waitTimeMinutes => DateTime.now().difference(orderTime).inMinutes;

  int? get prepTimeMinutes {
    if (startedAt == null || readyAt == null) return null;
    return readyAt!.difference(startedAt!).inMinutes;
  }

  bool isUrgent(int threshold) => waitTimeMinutes >= threshold;
  bool isVeryUrgent(int threshold) => waitTimeMinutes >= threshold;

  List<KitchenOrderItem> itemsByStation(String stationId) =>
      items.where((i) => i.stationId == stationId).toList();

  bool get isComplete =>
      items.every((i) => i.status == KitchenItemStatus.completed ||
          i.status == KitchenItemStatus.cancelled);

  double get completionPercentage {
    if (items.isEmpty) return 0;
    final done = items.where((i) =>
        i.status == KitchenItemStatus.completed ||
        i.status == KitchenItemStatus.cancelled).length;
    return done / items.length;
  }

  /// Items grouped by course number for hold-and-fire
  Map<int, List<KitchenOrderItem>> get byCourse {
    final map = <int, List<KitchenOrderItem>>{};
    for (final item in items) {
      final course = item.courseNumber ?? 1;
      map.putIfAbsent(course, () => []).add(item);
    }
    return map;
  }
}

@freezed
class KitchenOrderItem with _$KitchenOrderItem {
  const factory KitchenOrderItem({
    required String id,
    required String orderId,
    required String productId,
    required String productName,
    required int quantity,
    required KitchenItemStatus status,

    // Station
    String? stationId,
    String? stationName,

    // Seat
    int? seatNumber,

    // Modifiers
    @Default([]) List<KitchenItemModifier> modifiers,

    // Special requests
    String? specialInstructions,
    String? cookingPreference,

    // Timing
    DateTime? startedAt,
    DateTime? completedAt,
    String? preparedBy,

    // Course: 1=Appetiser 2=Main 3=Dessert
    int? courseNumber,

    // Display
    int? displayOrder,

    // 86'd
    @Default(false) bool is86d,

    // Void
    @Default(false) bool isCancelled,
    String? cancelReason,
    DateTime? cancelledAt,

    // Edit tracking
    @Default(false) bool isNewlyAdded,   // added via POS edit — highlight green
    @Default(false) bool isModified,     // modifier changed — highlight amber

    Map<String, dynamic>? metadata,
  }) = _KitchenOrderItem;

  const KitchenOrderItem._();

  factory KitchenOrderItem.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderItemFromJson(json);

  int? get prepTimeMinutes {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!).inMinutes;
  }

  bool get hasModifiers => modifiers.isNotEmpty;
  bool get hasSpecialInstructions =>
      specialInstructions != null && specialInstructions!.isNotEmpty;
  bool get hasCookingPreference =>
      cookingPreference != null && cookingPreference!.isNotEmpty;
  bool get isHeld => status == KitchenItemStatus.held;
}

@freezed
class KitchenItemModifier with _$KitchenItemModifier {
  const factory KitchenItemModifier({
    required String id,
    required String name,
    required ModifierAction action,
    String? notes,
  }) = _KitchenItemModifier;

  factory KitchenItemModifier.fromJson(Map<String, dynamic> json) =>
      _$KitchenItemModifierFromJson(json);
}

@freezed
class KitchenStation with _$KitchenStation {
  const factory KitchenStation({
    required String id,
    required String locationId,
    required String name,
    required KitchenStationType type,
    String? description,
    String? color,
    int? displayOrder,
    List<String>? assignedStaffIds,
    String? currentStaffId,
    String? currentStaffName,
    @Default(true) bool isActive,
    @Default(false) bool isPrinterEnabled,
    String? printerName,
    @Default([]) List<String> categoryIds,
    // Per-station thresholds (min)
    @Default(8)  int urgentThresholdMins,
    @Default(15) int veryUrgentThresholdMins,
    @Default(false) bool autoSoundEnabled,
    @Default(false) bool autoBumpEnabled,
    int? autoBumpAfterMins,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _KitchenStation;

  const KitchenStation._();

  factory KitchenStation.fromJson(Map<String, dynamic> json) =>
      _$KitchenStationFromJson(json);

  bool get hasStaff => currentStaffId != null;
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum KitchenOrderType {
  dineIn,
  takeaway,
  delivery,
  online,
  driveThrough;

  String get label {
    switch (this) {
      case KitchenOrderType.dineIn:       return 'Dine-In';
      case KitchenOrderType.takeaway:     return 'Takeaway';
      case KitchenOrderType.delivery:     return 'Delivery';
      case KitchenOrderType.online:       return 'Online';
      case KitchenOrderType.driveThrough: return 'Drive-Through';
    }
  }
}

enum KitchenOrderPriority {
  normal,
  high,
  urgent;

  String get label {
    switch (this) {
      case KitchenOrderPriority.normal: return 'Normal';
      case KitchenOrderPriority.high:   return 'High';
      case KitchenOrderPriority.urgent: return 'Urgent';
    }
  }
}

enum KitchenOrderStatus {
  pending,
  preparing,
  ready,
  bumped,
  served,
  recalled,
  cancelled;

  String get label {
    switch (this) {
      case KitchenOrderStatus.pending:   return 'Pending';
      case KitchenOrderStatus.preparing: return 'Preparing';
      case KitchenOrderStatus.ready:     return 'Ready';
      case KitchenOrderStatus.bumped:    return 'Bumped';
      case KitchenOrderStatus.served:    return 'Served';
      case KitchenOrderStatus.recalled:  return 'Recalled';
      case KitchenOrderStatus.cancelled: return 'Cancelled';
    }
  }

  bool get isActive => this == pending || this == preparing ||
      this == ready || this == recalled;
}

enum KitchenItemStatus {
  held,
  pending,
  preparing,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case KitchenItemStatus.held:      return 'Held';
      case KitchenItemStatus.pending:   return 'Pending';
      case KitchenItemStatus.preparing: return 'Preparing';
      case KitchenItemStatus.completed: return 'Completed';
      case KitchenItemStatus.cancelled: return 'Cancelled';
    }
  }

  bool get isHeld => this == KitchenItemStatus.held;
}

enum ModifierAction {
  add,
  remove,
  substitute,
  extra,
  light;

  String get label {
    switch (this) {
      case ModifierAction.add:        return 'Add';
      case ModifierAction.remove:     return 'No';
      case ModifierAction.substitute: return 'Sub';
      case ModifierAction.extra:      return 'Extra';
      case ModifierAction.light:      return 'Light';
    }
  }
}

enum KitchenStationType {
  grill,
  fryer,
  oven,
  coldPrep,
  hotPrep,
  bar,
  dessert,
  expo,
  pizza,
  salad;

  String get label {
    switch (this) {
      case KitchenStationType.grill:    return 'Grill';
      case KitchenStationType.fryer:    return 'Fryer';
      case KitchenStationType.oven:     return 'Oven';
      case KitchenStationType.coldPrep: return 'Cold Prep';
      case KitchenStationType.hotPrep:  return 'Hot Prep';
      case KitchenStationType.bar:      return 'Bar';
      case KitchenStationType.dessert:  return 'Dessert';
      case KitchenStationType.expo:     return 'Expo';
      case KitchenStationType.pizza:    return 'Pizza';
      case KitchenStationType.salad:    return 'Salad';
    }
  }
}
