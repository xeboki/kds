// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KitchenOrderImpl _$$KitchenOrderImplFromJson(Map<String, dynamic> json) =>
    _$KitchenOrderImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      locationId: json['locationId'] as String,
      tableNumber: json['tableNumber'] as String?,
      tableSectionName: json['tableSectionName'] as String?,
      guestCount: (json['guestCount'] as num?)?.toInt(),
      seatCount: (json['seatCount'] as num?)?.toInt(),
      orderNumber: json['orderNumber'] as String,
      orderType: $enumDecode(_$KitchenOrderTypeEnumMap, json['orderType']),
      priority: $enumDecode(_$KitchenOrderPriorityEnumMap, json['priority']),
      status: $enumDecode(_$KitchenOrderStatusEnumMap, json['status']),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => KitchenOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      serverId: json['serverId'] as String?,
      serverName: json['serverName'] as String?,
      preparedBy: json['preparedBy'] as String?,
      orderTime: DateTime.parse(json['orderTime'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      readyAt: json['readyAt'] == null
          ? null
          : DateTime.parse(json['readyAt'] as String),
      servedAt: json['servedAt'] == null
          ? null
          : DateTime.parse(json['servedAt'] as String),
      bumpedAt: json['bumpedAt'] == null
          ? null
          : DateTime.parse(json['bumpedAt'] as String),
      recalledAt: json['recalledAt'] == null
          ? null
          : DateTime.parse(json['recalledAt'] as String),
      scheduledFor: json['scheduledFor'] == null
          ? null
          : DateTime.parse(json['scheduledFor'] as String),
      specialInstructions: json['specialInstructions'] as String?,
      allergyInfo: json['allergyInfo'] as String?,
      assignedStations:
          (json['assignedStations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sourceLabel: json['sourceLabel'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$KitchenOrderImplToJson(_$KitchenOrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'locationId': instance.locationId,
      'tableNumber': instance.tableNumber,
      'tableSectionName': instance.tableSectionName,
      'guestCount': instance.guestCount,
      'seatCount': instance.seatCount,
      'orderNumber': instance.orderNumber,
      'orderType': _$KitchenOrderTypeEnumMap[instance.orderType]!,
      'priority': _$KitchenOrderPriorityEnumMap[instance.priority]!,
      'status': _$KitchenOrderStatusEnumMap[instance.status]!,
      'items': instance.items,
      'serverId': instance.serverId,
      'serverName': instance.serverName,
      'preparedBy': instance.preparedBy,
      'orderTime': instance.orderTime.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'readyAt': instance.readyAt?.toIso8601String(),
      'servedAt': instance.servedAt?.toIso8601String(),
      'bumpedAt': instance.bumpedAt?.toIso8601String(),
      'recalledAt': instance.recalledAt?.toIso8601String(),
      'scheduledFor': instance.scheduledFor?.toIso8601String(),
      'specialInstructions': instance.specialInstructions,
      'allergyInfo': instance.allergyInfo,
      'assignedStations': instance.assignedStations,
      'sourceLabel': instance.sourceLabel,
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
) => _$KitchenOrderItemImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  status: $enumDecode(_$KitchenItemStatusEnumMap, json['status']),
  stationId: json['stationId'] as String?,
  stationName: json['stationName'] as String?,
  seatNumber: (json['seatNumber'] as num?)?.toInt(),
  modifiers:
      (json['modifiers'] as List<dynamic>?)
          ?.map((e) => KitchenItemModifier.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  specialInstructions: json['specialInstructions'] as String?,
  cookingPreference: json['cookingPreference'] as String?,
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  preparedBy: json['preparedBy'] as String?,
  courseNumber: (json['courseNumber'] as num?)?.toInt(),
  displayOrder: (json['displayOrder'] as num?)?.toInt(),
  is86d: json['is86d'] as bool? ?? false,
  isCancelled: json['isCancelled'] as bool? ?? false,
  cancelReason: json['cancelReason'] as String?,
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  isNewlyAdded: json['isNewlyAdded'] as bool? ?? false,
  isModified: json['isModified'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$KitchenOrderItemImplToJson(
  _$KitchenOrderItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'productId': instance.productId,
  'productName': instance.productName,
  'quantity': instance.quantity,
  'status': _$KitchenItemStatusEnumMap[instance.status]!,
  'stationId': instance.stationId,
  'stationName': instance.stationName,
  'seatNumber': instance.seatNumber,
  'modifiers': instance.modifiers,
  'specialInstructions': instance.specialInstructions,
  'cookingPreference': instance.cookingPreference,
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'preparedBy': instance.preparedBy,
  'courseNumber': instance.courseNumber,
  'displayOrder': instance.displayOrder,
  'is86d': instance.is86d,
  'isCancelled': instance.isCancelled,
  'cancelReason': instance.cancelReason,
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
  'isNewlyAdded': instance.isNewlyAdded,
  'isModified': instance.isModified,
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
) => _$KitchenItemModifierImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  action: $enumDecode(_$ModifierActionEnumMap, json['action']),
  notes: json['notes'] as String?,
);

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

_$KitchenStationImpl _$$KitchenStationImplFromJson(Map<String, dynamic> json) =>
    _$KitchenStationImpl(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$KitchenStationTypeEnumMap, json['type']),
      description: json['description'] as String?,
      color: json['color'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      assignedStaffIds: (json['assignedStaffIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      currentStaffId: json['currentStaffId'] as String?,
      currentStaffName: json['currentStaffName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isPrinterEnabled: json['isPrinterEnabled'] as bool? ?? false,
      printerName: json['printerName'] as String?,
      categoryIds:
          (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      urgentThresholdMins: (json['urgentThresholdMins'] as num?)?.toInt() ?? 8,
      veryUrgentThresholdMins:
          (json['veryUrgentThresholdMins'] as num?)?.toInt() ?? 15,
      autoSoundEnabled: json['autoSoundEnabled'] as bool? ?? false,
      autoBumpEnabled: json['autoBumpEnabled'] as bool? ?? false,
      autoBumpAfterMins: (json['autoBumpAfterMins'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$KitchenStationImplToJson(
  _$KitchenStationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'locationId': instance.locationId,
  'name': instance.name,
  'type': _$KitchenStationTypeEnumMap[instance.type]!,
  'description': instance.description,
  'color': instance.color,
  'displayOrder': instance.displayOrder,
  'assignedStaffIds': instance.assignedStaffIds,
  'currentStaffId': instance.currentStaffId,
  'currentStaffName': instance.currentStaffName,
  'isActive': instance.isActive,
  'isPrinterEnabled': instance.isPrinterEnabled,
  'printerName': instance.printerName,
  'categoryIds': instance.categoryIds,
  'urgentThresholdMins': instance.urgentThresholdMins,
  'veryUrgentThresholdMins': instance.veryUrgentThresholdMins,
  'autoSoundEnabled': instance.autoSoundEnabled,
  'autoBumpEnabled': instance.autoBumpEnabled,
  'autoBumpAfterMins': instance.autoBumpAfterMins,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
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
