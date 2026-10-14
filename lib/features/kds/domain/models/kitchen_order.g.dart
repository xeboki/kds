// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KitchenOrderImpl _$$KitchenOrderImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$KitchenOrderImpl',
  json,
  ($checkedConvert) {
    final val = _$KitchenOrderImpl(
      id: $checkedConvert('id', (v) => v as String),
      orderId: $checkedConvert('order_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      tableNumber: $checkedConvert('table_number', (v) => v as String?),
      tableSectionName: $checkedConvert(
        'table_section_name',
        (v) => v as String?,
      ),
      guestCount: $checkedConvert('guest_count', (v) => (v as num?)?.toInt()),
      seatCount: $checkedConvert('seat_count', (v) => (v as num?)?.toInt()),
      orderNumber: $checkedConvert('order_number', (v) => v as String),
      orderType: $checkedConvert(
        'order_type',
        (v) =>
            $enumDecodeNullable(_$KitchenOrderTypeEnumMap, v) ??
            KitchenOrderType.dineIn,
      ),
      priority: $checkedConvert(
        'priority',
        (v) => $enumDecode(_$KitchenOrderPriorityEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$KitchenOrderStatusEnumMap, v),
      ),
      items: $checkedConvert(
        'items',
        (v) =>
            (v as List<dynamic>?)
                ?.map(
                  (e) => KitchenOrderItem.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
      ),
      serverId: $checkedConvert('server_id', (v) => v as String?),
      serverName: $checkedConvert('server_name', (v) => v as String?),
      preparedBy: $checkedConvert('prepared_by', (v) => v as String?),
      orderTime: $checkedConvert(
        'order_time',
        (v) => const RequiredTimestampConverter().fromJson(v),
      ),
      startedAt: $checkedConvert(
        'started_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      readyAt: $checkedConvert(
        'ready_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      servedAt: $checkedConvert(
        'served_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      bumpedAt: $checkedConvert(
        'bumped_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      recalledAt: $checkedConvert(
        'recalled_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      scheduledFor: $checkedConvert(
        'scheduled_for',
        (v) => const TimestampConverter().fromJson(v),
      ),
      specialInstructions: $checkedConvert(
        'special_instructions',
        (v) => v as String?,
      ),
      allergyInfo: $checkedConvert('allergy_info', (v) => v as String?),
      assignedStations: $checkedConvert(
        'assigned_stations',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      routingCategoryIds: $checkedConvert(
        'routing_category_ids',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      sourceLabel: $checkedConvert('source_label', (v) => v as String?),
      metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    );
    return val;
  },
  fieldKeyMap: const {
    'orderId': 'order_id',
    'locationId': 'location_id',
    'tableNumber': 'table_number',
    'tableSectionName': 'table_section_name',
    'guestCount': 'guest_count',
    'seatCount': 'seat_count',
    'orderNumber': 'order_number',
    'orderType': 'order_type',
    'serverId': 'server_id',
    'serverName': 'server_name',
    'preparedBy': 'prepared_by',
    'orderTime': 'order_time',
    'startedAt': 'started_at',
    'readyAt': 'ready_at',
    'servedAt': 'served_at',
    'bumpedAt': 'bumped_at',
    'recalledAt': 'recalled_at',
    'scheduledFor': 'scheduled_for',
    'specialInstructions': 'special_instructions',
    'allergyInfo': 'allergy_info',
    'assignedStations': 'assigned_stations',
    'routingCategoryIds': 'routing_category_ids',
    'sourceLabel': 'source_label',
  },
);

Map<String, dynamic> _$$KitchenOrderImplToJson(
  _$KitchenOrderImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'location_id': instance.locationId,
  'table_number': instance.tableNumber,
  'table_section_name': instance.tableSectionName,
  'guest_count': instance.guestCount,
  'seat_count': instance.seatCount,
  'order_number': instance.orderNumber,
  'order_type': _$KitchenOrderTypeEnumMap[instance.orderType]!,
  'priority': _$KitchenOrderPriorityEnumMap[instance.priority]!,
  'status': _$KitchenOrderStatusEnumMap[instance.status]!,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'server_id': instance.serverId,
  'server_name': instance.serverName,
  'prepared_by': instance.preparedBy,
  'order_time': const RequiredTimestampConverter().toJson(instance.orderTime),
  'started_at': const TimestampConverter().toJson(instance.startedAt),
  'ready_at': const TimestampConverter().toJson(instance.readyAt),
  'served_at': const TimestampConverter().toJson(instance.servedAt),
  'bumped_at': const TimestampConverter().toJson(instance.bumpedAt),
  'recalled_at': const TimestampConverter().toJson(instance.recalledAt),
  'scheduled_for': const TimestampConverter().toJson(instance.scheduledFor),
  'special_instructions': instance.specialInstructions,
  'allergy_info': instance.allergyInfo,
  'assigned_stations': instance.assignedStations,
  'routing_category_ids': instance.routingCategoryIds,
  'source_label': instance.sourceLabel,
  'metadata': instance.metadata,
};

const _$KitchenOrderTypeEnumMap = {
  KitchenOrderType.dineIn: 'dineIn',
  KitchenOrderType.takeaway: 'takeaway',
  KitchenOrderType.delivery: 'delivery',
  KitchenOrderType.online: 'online',
  KitchenOrderType.driveThrough: 'driveThrough',
};

const _$KitchenOrderPriorityEnumMap = {
  KitchenOrderPriority.normal: 'normal',
  KitchenOrderPriority.high: 'high',
  KitchenOrderPriority.urgent: 'urgent',
};

const _$KitchenOrderStatusEnumMap = {
  KitchenOrderStatus.pending: 'pending',
  KitchenOrderStatus.preparing: 'preparing',
  KitchenOrderStatus.ready: 'ready',
  KitchenOrderStatus.bumped: 'bumped',
  KitchenOrderStatus.served: 'served',
  KitchenOrderStatus.recalled: 'recalled',
  KitchenOrderStatus.cancelled: 'cancelled',
};

_$KitchenOrderItemImpl _$$KitchenOrderItemImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$KitchenOrderItemImpl',
  json,
  ($checkedConvert) {
    final val = _$KitchenOrderItemImpl(
      id: $checkedConvert('id', (v) => v as String),
      orderId: $checkedConvert('order_id', (v) => v as String),
      productId: $checkedConvert('product_id', (v) => v as String),
      productName: $checkedConvert('product_name', (v) => v as String),
      quantity: $checkedConvert('quantity', (v) => (v as num).toInt()),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$KitchenItemStatusEnumMap, v),
      ),
      stationId: $checkedConvert('station_id', (v) => v as String?),
      stationName: $checkedConvert('station_name', (v) => v as String?),
      routingCategoryIds: $checkedConvert(
        'routing_category_ids',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      isUnclaimed: $checkedConvert('is_unclaimed', (v) => v as bool? ?? false),
      seatNumber: $checkedConvert('seat_number', (v) => (v as num?)?.toInt()),
      modifiers: $checkedConvert(
        'modifiers',
        (v) =>
            (v as List<dynamic>?)
                ?.map(
                  (e) =>
                      KitchenItemModifier.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
      ),
      specialInstructions: $checkedConvert(
        'special_instructions',
        (v) => v as String?,
      ),
      cookingPreference: $checkedConvert(
        'cooking_preference',
        (v) => v as String?,
      ),
      startedAt: $checkedConvert(
        'started_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      completedAt: $checkedConvert(
        'completed_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      preparedBy: $checkedConvert('prepared_by', (v) => v as String?),
      courseNumber: $checkedConvert(
        'course_number',
        (v) => (v as num?)?.toInt(),
      ),
      displayOrder: $checkedConvert(
        'display_order',
        (v) => (v as num?)?.toInt(),
      ),
      is86d: $checkedConvert('is86d', (v) => v as bool? ?? false),
      isCancelled: $checkedConvert('is_cancelled', (v) => v as bool? ?? false),
      cancelReason: $checkedConvert('cancel_reason', (v) => v as String?),
      cancelledAt: $checkedConvert(
        'cancelled_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      isNewlyAdded: $checkedConvert(
        'is_newly_added',
        (v) => v as bool? ?? false,
      ),
      isModified: $checkedConvert('is_modified', (v) => v as bool? ?? false),
      metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    );
    return val;
  },
  fieldKeyMap: const {
    'orderId': 'order_id',
    'productId': 'product_id',
    'productName': 'product_name',
    'stationId': 'station_id',
    'stationName': 'station_name',
    'routingCategoryIds': 'routing_category_ids',
    'isUnclaimed': 'is_unclaimed',
    'seatNumber': 'seat_number',
    'specialInstructions': 'special_instructions',
    'cookingPreference': 'cooking_preference',
    'startedAt': 'started_at',
    'completedAt': 'completed_at',
    'preparedBy': 'prepared_by',
    'courseNumber': 'course_number',
    'displayOrder': 'display_order',
    'isCancelled': 'is_cancelled',
    'cancelReason': 'cancel_reason',
    'cancelledAt': 'cancelled_at',
    'isNewlyAdded': 'is_newly_added',
    'isModified': 'is_modified',
  },
);

Map<String, dynamic> _$$KitchenOrderItemImplToJson(
  _$KitchenOrderItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'product_id': instance.productId,
  'product_name': instance.productName,
  'quantity': instance.quantity,
  'status': _$KitchenItemStatusEnumMap[instance.status]!,
  'station_id': instance.stationId,
  'station_name': instance.stationName,
  'routing_category_ids': instance.routingCategoryIds,
  'is_unclaimed': instance.isUnclaimed,
  'seat_number': instance.seatNumber,
  'modifiers': instance.modifiers.map((e) => e.toJson()).toList(),
  'special_instructions': instance.specialInstructions,
  'cooking_preference': instance.cookingPreference,
  'started_at': const TimestampConverter().toJson(instance.startedAt),
  'completed_at': const TimestampConverter().toJson(instance.completedAt),
  'prepared_by': instance.preparedBy,
  'course_number': instance.courseNumber,
  'display_order': instance.displayOrder,
  'is86d': instance.is86d,
  'is_cancelled': instance.isCancelled,
  'cancel_reason': instance.cancelReason,
  'cancelled_at': const TimestampConverter().toJson(instance.cancelledAt),
  'is_newly_added': instance.isNewlyAdded,
  'is_modified': instance.isModified,
  'metadata': instance.metadata,
};

const _$KitchenItemStatusEnumMap = {
  KitchenItemStatus.held: 'held',
  KitchenItemStatus.pending: 'pending',
  KitchenItemStatus.preparing: 'preparing',
  KitchenItemStatus.completed: 'completed',
  KitchenItemStatus.cancelled: 'cancelled',
};

_$KitchenItemModifierImpl _$$KitchenItemModifierImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$KitchenItemModifierImpl', json, ($checkedConvert) {
  final val = _$KitchenItemModifierImpl(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    action: $checkedConvert(
      'action',
      (v) => $enumDecode(_$ModifierActionEnumMap, v),
    ),
    notes: $checkedConvert('notes', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$KitchenItemModifierImplToJson(
  _$KitchenItemModifierImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'action': _$ModifierActionEnumMap[instance.action]!,
  'notes': instance.notes,
};

const _$ModifierActionEnumMap = {
  ModifierAction.add: 'add',
  ModifierAction.remove: 'remove',
  ModifierAction.substitute: 'substitute',
  ModifierAction.extra: 'extra',
  ModifierAction.light: 'light',
};

_$KitchenStationImpl _$$KitchenStationImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$KitchenStationImpl',
  json,
  ($checkedConvert) {
    final val = _$KitchenStationImpl(
      id: $checkedConvert('id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(_$KitchenStationTypeEnumMap, v),
      ),
      description: $checkedConvert('description', (v) => v as String?),
      color: $checkedConvert('color', (v) => v as String?),
      displayOrder: $checkedConvert(
        'display_order',
        (v) => (v as num?)?.toInt(),
      ),
      assignedStaffIds: $checkedConvert(
        'assigned_staff_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      currentStaffId: $checkedConvert('current_staff_id', (v) => v as String?),
      currentStaffName: $checkedConvert(
        'current_staff_name',
        (v) => v as String?,
      ),
      isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
      isPrinterEnabled: $checkedConvert(
        'is_printer_enabled',
        (v) => v as bool? ?? false,
      ),
      printerName: $checkedConvert('printer_name', (v) => v as String?),
      categoryIds: $checkedConvert(
        'category_ids',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      urgentThresholdMins: $checkedConvert(
        'urgent_threshold_mins',
        (v) => (v as num?)?.toInt() ?? 8,
      ),
      veryUrgentThresholdMins: $checkedConvert(
        'very_urgent_threshold_mins',
        (v) => (v as num?)?.toInt() ?? 15,
      ),
      autoSoundEnabled: $checkedConvert(
        'auto_sound_enabled',
        (v) => v as bool? ?? false,
      ),
      autoBumpEnabled: $checkedConvert(
        'auto_bump_enabled',
        (v) => v as bool? ?? false,
      ),
      autoBumpAfterMins: $checkedConvert(
        'auto_bump_after_mins',
        (v) => (v as num?)?.toInt(),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => const TimestampConverter().fromJson(v),
      ),
      metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    );
    return val;
  },
  fieldKeyMap: const {
    'locationId': 'location_id',
    'displayOrder': 'display_order',
    'assignedStaffIds': 'assigned_staff_ids',
    'currentStaffId': 'current_staff_id',
    'currentStaffName': 'current_staff_name',
    'isActive': 'is_active',
    'isPrinterEnabled': 'is_printer_enabled',
    'printerName': 'printer_name',
    'categoryIds': 'category_ids',
    'urgentThresholdMins': 'urgent_threshold_mins',
    'veryUrgentThresholdMins': 'very_urgent_threshold_mins',
    'autoSoundEnabled': 'auto_sound_enabled',
    'autoBumpEnabled': 'auto_bump_enabled',
    'autoBumpAfterMins': 'auto_bump_after_mins',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$$KitchenStationImplToJson(
  _$KitchenStationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'location_id': instance.locationId,
  'name': instance.name,
  'type': _$KitchenStationTypeEnumMap[instance.type]!,
  'description': instance.description,
  'color': instance.color,
  'display_order': instance.displayOrder,
  'assigned_staff_ids': instance.assignedStaffIds,
  'current_staff_id': instance.currentStaffId,
  'current_staff_name': instance.currentStaffName,
  'is_active': instance.isActive,
  'is_printer_enabled': instance.isPrinterEnabled,
  'printer_name': instance.printerName,
  'category_ids': instance.categoryIds,
  'urgent_threshold_mins': instance.urgentThresholdMins,
  'very_urgent_threshold_mins': instance.veryUrgentThresholdMins,
  'auto_sound_enabled': instance.autoSoundEnabled,
  'auto_bump_enabled': instance.autoBumpEnabled,
  'auto_bump_after_mins': instance.autoBumpAfterMins,
  'created_at': const TimestampConverter().toJson(instance.createdAt),
  'updated_at': const TimestampConverter().toJson(instance.updatedAt),
  'metadata': instance.metadata,
};

const _$KitchenStationTypeEnumMap = {
  KitchenStationType.grill: 'grill',
  KitchenStationType.fryer: 'fryer',
  KitchenStationType.oven: 'oven',
  KitchenStationType.coldPrep: 'coldPrep',
  KitchenStationType.hotPrep: 'hotPrep',
  KitchenStationType.bar: 'bar',
  KitchenStationType.dessert: 'dessert',
  KitchenStationType.expo: 'expo',
  KitchenStationType.pizza: 'pizza',
  KitchenStationType.salad: 'salad',
};
