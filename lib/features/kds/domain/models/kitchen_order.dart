import 'package:freezed_annotation/freezed_annotation.dart';

import 'screen_role.dart';
import 'timestamp_converter.dart';

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
    /// SPEC-097. Defaulted, not required.
    ///
    /// Neither writer emits a top-level `order_type`: the till's own
    /// `KitchenOrder` has no such field at all, and the API records it only
    /// inside `metadata`. With `checked: true` a missing required field
    /// **throws**, so every real ticket crashed this app — the board rendered
    /// blank and threw on every frame rather than showing an empty state.
    ///
    /// Dine-in is the right default for a legacy document: the till only
    /// sends dine-in orders to the kitchen at all (`_sendToKitchen` returns
    /// early for anything else). A kitchen ticket is short-lived, so the few
    /// older online ones age out within a service.
    @Default(KitchenOrderType.dineIn) KitchenOrderType orderType,
    required KitchenOrderPriority priority,
    required KitchenOrderStatus status,

    // Items
    @Default([]) List<KitchenOrderItem> items,

    // Staff
    String? serverId,
    String? serverName,
    String? preparedBy,

    // Timing
    @RequiredTimestampConverter() required DateTime orderTime,
    @TimestampConverter() DateTime? startedAt,
    @TimestampConverter() DateTime? readyAt,
    @TimestampConverter() DateTime? servedAt,
    @TimestampConverter() DateTime? bumpedAt,
    @TimestampConverter() DateTime? recalledAt,
    @TimestampConverter() DateTime? scheduledFor,

    // Notes
    String? specialInstructions,
    String? allergyInfo,

    // Station routing
    @Default([]) List<String> assignedStations,

    /// The union of its lines' routing categories.
    @Default([]) List<String> routingCategoryIds,

    // Source
    String? sourceLabel, // 'DoorDash', 'Uber Eats', 'Online', etc.

    // Metadata
    Map<String, dynamic>? metadata,
  }) = _KitchenOrder;

  const KitchenOrder._();

  factory KitchenOrder.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderFromJson(json);

  /// When the kitchen is meant to have this ready.
  ///
  /// The time it was asked for if it was asked for a time, else the time it
  /// was rung. Every timer and every wait statistic measures from here, so a
  /// pre-order is not treated as late for the hours between being taken and
  /// being due — before this, `scheduledFor` was read off the wire and used
  /// nowhere, so a Saturday-night catering order rang in on Thursday went red
  /// on the board within 20 minutes and skewed the average wait by two days.
  DateTime get dueAt => scheduledFor ?? orderTime;

  /// Asked for a time that has not come yet.
  bool get isScheduledAhead =>
      scheduledFor != null && scheduledFor!.isAfter(DateTime.now());

  /// Minutes past due. Negative while a scheduled order is still ahead of
  /// its time, so callers averaging it must drop those first.
  int get waitTimeMinutes => DateTime.now().difference(dueAt).inMinutes;

  int? get prepTimeMinutes {
    if (startedAt == null || readyAt == null) return null;
    return readyAt!.difference(startedAt!).inMinutes;
  }

  bool isUrgent(int threshold) => waitTimeMinutes >= threshold;
  bool isVeryUrgent(int threshold) => waitTimeMinutes >= threshold;

  List<KitchenOrderItem> itemsByStation(String stationId) =>
      items.where((i) => i.stationId == stationId).toList();

  /// The lines this screen is responsible for.
  ///
  /// SPEC-097, Square's model. The whole rule is `screenShowsLine`, which this
  /// defers to rather than restating — a board that filters its orders by one
  /// answer and its lines by another shows a ticket with nothing on it.
  ///
  /// An expo screen sees every line. A prep screen sees the routing categories
  /// it is switched on for, **plus anything nobody claimed** — hiding those
  /// would put a line on no screen at all and it would never be cooked.
  List<KitchenOrderItem> linesFor(
    List<String> screenRoutingCategoryIds, {
    bool isExpo = false,
  }) =>
      items
          .where((i) => screenShowsLine(
                lineRoutingCategoryIds: i.routingCategoryIds,
                screenRoutingCategoryIds: screenRoutingCategoryIds,
                isExpo: isExpo,
              ))
          .toList()
        // The till decides the order lines were rung in and sends it as
        // `displayOrder`; the board ignored it and drew whatever order the
        // array happened to hold. A stable fallback keeps lines without one
        // in their arrival order rather than shuffling them.
        ..sort((a, b) => (a.displayOrder ?? 1 << 30)
            .compareTo(b.displayOrder ?? 1 << 30));

  /// [byCourse], narrowed the same way as [linesFor].
  Map<int, List<KitchenOrderItem>> coursesFor(
    List<String> screenRoutingCategoryIds, {
    bool isExpo = false,
  }) {
    final map = <int, List<KitchenOrderItem>>{};
    for (final item
        in linesFor(screenRoutingCategoryIds, isExpo: isExpo)) {
      map.putIfAbsent(item.courseNumber ?? 1, () => []).add(item);
    }
    return map;
  }

  bool get isComplete => items
      .every((i) => i.status == KitchenItemStatus.completed || i.isVoided);

  double get completionPercentage {
    if (items.isEmpty) return 0;
    final done = items
        .where((i) => i.status == KitchenItemStatus.completed || i.isVoided)
        .length;
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

    /// SPEC-097, Square's model. The kitchen routing categories that claimed
    /// this line. Several is normal — an item can be in more than one.
    @Default([]) List<String> routingCategoryIds,

    /// Nobody claimed it. Said on the line rather than inferred from an empty
    /// list, because a reader working it out from emptiness will one day meet
    /// an empty list that means "not routed yet" instead, and hide the line.
    @Default(false) bool isUnclaimed,

    // Seat
    int? seatNumber,

    // Modifiers
    @Default([]) List<KitchenItemModifier> modifiers,

    // Special requests
    String? specialInstructions,
    String? cookingPreference,

    // Timing
    @TimestampConverter() DateTime? startedAt,
    @TimestampConverter() DateTime? completedAt,
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
    @TimestampConverter() DateTime? cancelledAt,

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

  /// Nobody is going to cook this.
  ///
  /// Two fields can mean a line is off and they were checked in different
  /// places: the status, and `isCancelled` — the void flag the till sets when
  /// a server voids a dish, which **nothing** checked. A voided dish was
  /// drawn as an ordinary line, counted in the all-day, and cooked.
  bool get isVoided =>
      isCancelled || status == KitchenItemStatus.cancelled;

  /// Off the board one way or another: voided, or 86'd because the kitchen
  /// has run out. Neither should be counted as work to do.
  bool get isOff => isVoided || is86d;
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
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
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
