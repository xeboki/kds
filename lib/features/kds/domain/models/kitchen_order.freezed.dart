// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kitchen_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KitchenOrder _$KitchenOrderFromJson(Map<String, dynamic> json) {
  return _KitchenOrder.fromJson(json);
}

/// @nodoc
mixin _$KitchenOrder {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get locationId => throw _privateConstructorUsedError; // Table info
  String? get tableNumber => throw _privateConstructorUsedError;
  String? get tableSectionName => throw _privateConstructorUsedError;
  int? get guestCount => throw _privateConstructorUsedError;
  int? get seatCount => throw _privateConstructorUsedError; // Order info
  String get orderNumber => throw _privateConstructorUsedError;
  KitchenOrderType get orderType => throw _privateConstructorUsedError;
  KitchenOrderPriority get priority => throw _privateConstructorUsedError;
  KitchenOrderStatus get status => throw _privateConstructorUsedError; // Items
  List<KitchenOrderItem> get items =>
      throw _privateConstructorUsedError; // Staff
  String? get serverId => throw _privateConstructorUsedError;
  String? get serverName => throw _privateConstructorUsedError;
  String? get preparedBy => throw _privateConstructorUsedError; // Timing
  DateTime get orderTime => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get readyAt => throw _privateConstructorUsedError;
  DateTime? get servedAt => throw _privateConstructorUsedError;
  DateTime? get bumpedAt => throw _privateConstructorUsedError;
  DateTime? get recalledAt => throw _privateConstructorUsedError;
  DateTime? get scheduledFor => throw _privateConstructorUsedError; // Notes
  String? get specialInstructions => throw _privateConstructorUsedError;
  String? get allergyInfo =>
      throw _privateConstructorUsedError; // Station routing
  List<String> get assignedStations =>
      throw _privateConstructorUsedError; // Source
  String? get sourceLabel =>
      throw _privateConstructorUsedError; // 'DoorDash', 'Uber Eats', 'Online', etc.
  // Metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this KitchenOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitchenOrderCopyWith<KitchenOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitchenOrderCopyWith<$Res> {
  factory $KitchenOrderCopyWith(
    KitchenOrder value,
    $Res Function(KitchenOrder) then,
  ) = _$KitchenOrderCopyWithImpl<$Res, KitchenOrder>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String locationId,
    String? tableNumber,
    String? tableSectionName,
    int? guestCount,
    int? seatCount,
    String orderNumber,
    KitchenOrderType orderType,
    KitchenOrderPriority priority,
    KitchenOrderStatus status,
    List<KitchenOrderItem> items,
    String? serverId,
    String? serverName,
    String? preparedBy,
    DateTime orderTime,
    DateTime? startedAt,
    DateTime? readyAt,
    DateTime? servedAt,
    DateTime? bumpedAt,
    DateTime? recalledAt,
    DateTime? scheduledFor,
    String? specialInstructions,
    String? allergyInfo,
    List<String> assignedStations,
    String? sourceLabel,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$KitchenOrderCopyWithImpl<$Res, $Val extends KitchenOrder>
    implements $KitchenOrderCopyWith<$Res> {
  _$KitchenOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? locationId = null,
    Object? tableNumber = freezed,
    Object? tableSectionName = freezed,
    Object? guestCount = freezed,
    Object? seatCount = freezed,
    Object? orderNumber = null,
    Object? orderType = null,
    Object? priority = null,
    Object? status = null,
    Object? items = null,
    Object? serverId = freezed,
    Object? serverName = freezed,
    Object? preparedBy = freezed,
    Object? orderTime = null,
    Object? startedAt = freezed,
    Object? readyAt = freezed,
    Object? servedAt = freezed,
    Object? bumpedAt = freezed,
    Object? recalledAt = freezed,
    Object? scheduledFor = freezed,
    Object? specialInstructions = freezed,
    Object? allergyInfo = freezed,
    Object? assignedStations = null,
    Object? sourceLabel = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            locationId: null == locationId
                ? _value.locationId
                : locationId // ignore: cast_nullable_to_non_nullable
                      as String,
            tableNumber: freezed == tableNumber
                ? _value.tableNumber
                : tableNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            tableSectionName: freezed == tableSectionName
                ? _value.tableSectionName
                : tableSectionName // ignore: cast_nullable_to_non_nullable
                      as String?,
            guestCount: freezed == guestCount
                ? _value.guestCount
                : guestCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            seatCount: freezed == seatCount
                ? _value.seatCount
                : seatCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            orderNumber: null == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            orderType: null == orderType
                ? _value.orderType
                : orderType // ignore: cast_nullable_to_non_nullable
                      as KitchenOrderType,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as KitchenOrderPriority,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as KitchenOrderStatus,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<KitchenOrderItem>,
            serverId: freezed == serverId
                ? _value.serverId
                : serverId // ignore: cast_nullable_to_non_nullable
                      as String?,
            serverName: freezed == serverName
                ? _value.serverName
                : serverName // ignore: cast_nullable_to_non_nullable
                      as String?,
            preparedBy: freezed == preparedBy
                ? _value.preparedBy
                : preparedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            orderTime: null == orderTime
                ? _value.orderTime
                : orderTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            readyAt: freezed == readyAt
                ? _value.readyAt
                : readyAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            servedAt: freezed == servedAt
                ? _value.servedAt
                : servedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            bumpedAt: freezed == bumpedAt
                ? _value.bumpedAt
                : bumpedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            recalledAt: freezed == recalledAt
                ? _value.recalledAt
                : recalledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            scheduledFor: freezed == scheduledFor
                ? _value.scheduledFor
                : scheduledFor // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            specialInstructions: freezed == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
                      as String?,
            allergyInfo: freezed == allergyInfo
                ? _value.allergyInfo
                : allergyInfo // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedStations: null == assignedStations
                ? _value.assignedStations
                : assignedStations // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            sourceLabel: freezed == sourceLabel
                ? _value.sourceLabel
                : sourceLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KitchenOrderImplCopyWith<$Res>
    implements $KitchenOrderCopyWith<$Res> {
  factory _$$KitchenOrderImplCopyWith(
    _$KitchenOrderImpl value,
    $Res Function(_$KitchenOrderImpl) then,
  ) = __$$KitchenOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String locationId,
    String? tableNumber,
    String? tableSectionName,
    int? guestCount,
    int? seatCount,
    String orderNumber,
    KitchenOrderType orderType,
    KitchenOrderPriority priority,
    KitchenOrderStatus status,
    List<KitchenOrderItem> items,
    String? serverId,
    String? serverName,
    String? preparedBy,
    DateTime orderTime,
    DateTime? startedAt,
    DateTime? readyAt,
    DateTime? servedAt,
    DateTime? bumpedAt,
    DateTime? recalledAt,
    DateTime? scheduledFor,
    String? specialInstructions,
    String? allergyInfo,
    List<String> assignedStations,
    String? sourceLabel,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$KitchenOrderImplCopyWithImpl<$Res>
    extends _$KitchenOrderCopyWithImpl<$Res, _$KitchenOrderImpl>
    implements _$$KitchenOrderImplCopyWith<$Res> {
  __$$KitchenOrderImplCopyWithImpl(
    _$KitchenOrderImpl _value,
    $Res Function(_$KitchenOrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? locationId = null,
    Object? tableNumber = freezed,
    Object? tableSectionName = freezed,
    Object? guestCount = freezed,
    Object? seatCount = freezed,
    Object? orderNumber = null,
    Object? orderType = null,
    Object? priority = null,
    Object? status = null,
    Object? items = null,
    Object? serverId = freezed,
    Object? serverName = freezed,
    Object? preparedBy = freezed,
    Object? orderTime = null,
    Object? startedAt = freezed,
    Object? readyAt = freezed,
    Object? servedAt = freezed,
    Object? bumpedAt = freezed,
    Object? recalledAt = freezed,
    Object? scheduledFor = freezed,
    Object? specialInstructions = freezed,
    Object? allergyInfo = freezed,
    Object? assignedStations = null,
    Object? sourceLabel = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$KitchenOrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        locationId: null == locationId
            ? _value.locationId
            : locationId // ignore: cast_nullable_to_non_nullable
                  as String,
        tableNumber: freezed == tableNumber
            ? _value.tableNumber
            : tableNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        tableSectionName: freezed == tableSectionName
            ? _value.tableSectionName
            : tableSectionName // ignore: cast_nullable_to_non_nullable
                  as String?,
        guestCount: freezed == guestCount
            ? _value.guestCount
            : guestCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        seatCount: freezed == seatCount
            ? _value.seatCount
            : seatCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        orderType: null == orderType
            ? _value.orderType
            : orderType // ignore: cast_nullable_to_non_nullable
                  as KitchenOrderType,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as KitchenOrderPriority,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as KitchenOrderStatus,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<KitchenOrderItem>,
        serverId: freezed == serverId
            ? _value.serverId
            : serverId // ignore: cast_nullable_to_non_nullable
                  as String?,
        serverName: freezed == serverName
            ? _value.serverName
            : serverName // ignore: cast_nullable_to_non_nullable
                  as String?,
        preparedBy: freezed == preparedBy
            ? _value.preparedBy
            : preparedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        orderTime: null == orderTime
            ? _value.orderTime
            : orderTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        readyAt: freezed == readyAt
            ? _value.readyAt
            : readyAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        servedAt: freezed == servedAt
            ? _value.servedAt
            : servedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        bumpedAt: freezed == bumpedAt
            ? _value.bumpedAt
            : bumpedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        recalledAt: freezed == recalledAt
            ? _value.recalledAt
            : recalledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        scheduledFor: freezed == scheduledFor
            ? _value.scheduledFor
            : scheduledFor // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        specialInstructions: freezed == specialInstructions
            ? _value.specialInstructions
            : specialInstructions // ignore: cast_nullable_to_non_nullable
                  as String?,
        allergyInfo: freezed == allergyInfo
            ? _value.allergyInfo
            : allergyInfo // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedStations: null == assignedStations
            ? _value._assignedStations
            : assignedStations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        sourceLabel: freezed == sourceLabel
            ? _value.sourceLabel
            : sourceLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KitchenOrderImpl extends _KitchenOrder {
  const _$KitchenOrderImpl({
    required this.id,
    required this.orderId,
    required this.locationId,
    this.tableNumber,
    this.tableSectionName,
    this.guestCount,
    this.seatCount,
    required this.orderNumber,
    required this.orderType,
    required this.priority,
    required this.status,
    final List<KitchenOrderItem> items = const [],
    this.serverId,
    this.serverName,
    this.preparedBy,
    required this.orderTime,
    this.startedAt,
    this.readyAt,
    this.servedAt,
    this.bumpedAt,
    this.recalledAt,
    this.scheduledFor,
    this.specialInstructions,
    this.allergyInfo,
    final List<String> assignedStations = const [],
    this.sourceLabel,
    final Map<String, dynamic>? metadata,
  }) : _items = items,
       _assignedStations = assignedStations,
       _metadata = metadata,
       super._();

  factory _$KitchenOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$KitchenOrderImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String locationId;
  // Table info
  @override
  final String? tableNumber;
  @override
  final String? tableSectionName;
  @override
  final int? guestCount;
  @override
  final int? seatCount;
  // Order info
  @override
  final String orderNumber;
  @override
  final KitchenOrderType orderType;
  @override
  final KitchenOrderPriority priority;
  @override
  final KitchenOrderStatus status;
  // Items
  final List<KitchenOrderItem> _items;
  // Items
  @override
  @JsonKey()
  List<KitchenOrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  // Staff
  @override
  final String? serverId;
  @override
  final String? serverName;
  @override
  final String? preparedBy;
  // Timing
  @override
  final DateTime orderTime;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? servedAt;
  @override
  final DateTime? bumpedAt;
  @override
  final DateTime? recalledAt;
  @override
  final DateTime? scheduledFor;
  // Notes
  @override
  final String? specialInstructions;
  @override
  final String? allergyInfo;
  // Station routing
  final List<String> _assignedStations;
  // Station routing
  @override
  @JsonKey()
  List<String> get assignedStations {
    if (_assignedStations is EqualUnmodifiableListView)
      return _assignedStations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedStations);
  }

  // Source
  @override
  final String? sourceLabel;
  // 'DoorDash', 'Uber Eats', 'Online', etc.
  // Metadata
  final Map<String, dynamic>? _metadata;
  // 'DoorDash', 'Uber Eats', 'Online', etc.
  // Metadata
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'KitchenOrder(id: $id, orderId: $orderId, locationId: $locationId, tableNumber: $tableNumber, tableSectionName: $tableSectionName, guestCount: $guestCount, seatCount: $seatCount, orderNumber: $orderNumber, orderType: $orderType, priority: $priority, status: $status, items: $items, serverId: $serverId, serverName: $serverName, preparedBy: $preparedBy, orderTime: $orderTime, startedAt: $startedAt, readyAt: $readyAt, servedAt: $servedAt, bumpedAt: $bumpedAt, recalledAt: $recalledAt, scheduledFor: $scheduledFor, specialInstructions: $specialInstructions, allergyInfo: $allergyInfo, assignedStations: $assignedStations, sourceLabel: $sourceLabel, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitchenOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.tableNumber, tableNumber) ||
                other.tableNumber == tableNumber) &&
            (identical(other.tableSectionName, tableSectionName) ||
                other.tableSectionName == tableSectionName) &&
            (identical(other.guestCount, guestCount) ||
                other.guestCount == guestCount) &&
            (identical(other.seatCount, seatCount) ||
                other.seatCount == seatCount) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.preparedBy, preparedBy) ||
                other.preparedBy == preparedBy) &&
            (identical(other.orderTime, orderTime) ||
                other.orderTime == orderTime) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.readyAt, readyAt) || other.readyAt == readyAt) &&
            (identical(other.servedAt, servedAt) ||
                other.servedAt == servedAt) &&
            (identical(other.bumpedAt, bumpedAt) ||
                other.bumpedAt == bumpedAt) &&
            (identical(other.recalledAt, recalledAt) ||
                other.recalledAt == recalledAt) &&
            (identical(other.scheduledFor, scheduledFor) ||
                other.scheduledFor == scheduledFor) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.allergyInfo, allergyInfo) ||
                other.allergyInfo == allergyInfo) &&
            const DeepCollectionEquality().equals(
              other._assignedStations,
              _assignedStations,
            ) &&
            (identical(other.sourceLabel, sourceLabel) ||
                other.sourceLabel == sourceLabel) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderId,
    locationId,
    tableNumber,
    tableSectionName,
    guestCount,
    seatCount,
    orderNumber,
    orderType,
    priority,
    status,
    const DeepCollectionEquality().hash(_items),
    serverId,
    serverName,
    preparedBy,
    orderTime,
    startedAt,
    readyAt,
    servedAt,
    bumpedAt,
    recalledAt,
    scheduledFor,
    specialInstructions,
    allergyInfo,
    const DeepCollectionEquality().hash(_assignedStations),
    sourceLabel,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitchenOrderImplCopyWith<_$KitchenOrderImpl> get copyWith =>
      __$$KitchenOrderImplCopyWithImpl<_$KitchenOrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KitchenOrderImplToJson(this);
  }
}

abstract class _KitchenOrder extends KitchenOrder {
  const factory _KitchenOrder({
    required final String id,
    required final String orderId,
    required final String locationId,
    final String? tableNumber,
    final String? tableSectionName,
    final int? guestCount,
    final int? seatCount,
    required final String orderNumber,
    required final KitchenOrderType orderType,
    required final KitchenOrderPriority priority,
    required final KitchenOrderStatus status,
    final List<KitchenOrderItem> items,
    final String? serverId,
    final String? serverName,
    final String? preparedBy,
    required final DateTime orderTime,
    final DateTime? startedAt,
    final DateTime? readyAt,
    final DateTime? servedAt,
    final DateTime? bumpedAt,
    final DateTime? recalledAt,
    final DateTime? scheduledFor,
    final String? specialInstructions,
    final String? allergyInfo,
    final List<String> assignedStations,
    final String? sourceLabel,
    final Map<String, dynamic>? metadata,
  }) = _$KitchenOrderImpl;
  const _KitchenOrder._() : super._();

  factory _KitchenOrder.fromJson(Map<String, dynamic> json) =
      _$KitchenOrderImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get locationId; // Table info
  @override
  String? get tableNumber;
  @override
  String? get tableSectionName;
  @override
  int? get guestCount;
  @override
  int? get seatCount; // Order info
  @override
  String get orderNumber;
  @override
  KitchenOrderType get orderType;
  @override
  KitchenOrderPriority get priority;
  @override
  KitchenOrderStatus get status; // Items
  @override
  List<KitchenOrderItem> get items; // Staff
  @override
  String? get serverId;
  @override
  String? get serverName;
  @override
  String? get preparedBy; // Timing
  @override
  DateTime get orderTime;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get readyAt;
  @override
  DateTime? get servedAt;
  @override
  DateTime? get bumpedAt;
  @override
  DateTime? get recalledAt;
  @override
  DateTime? get scheduledFor; // Notes
  @override
  String? get specialInstructions;
  @override
  String? get allergyInfo; // Station routing
  @override
  List<String> get assignedStations; // Source
  @override
  String? get sourceLabel; // 'DoorDash', 'Uber Eats', 'Online', etc.
  // Metadata
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitchenOrderImplCopyWith<_$KitchenOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KitchenOrderItem _$KitchenOrderItemFromJson(Map<String, dynamic> json) {
  return _KitchenOrderItem.fromJson(json);
}

/// @nodoc
mixin _$KitchenOrderItem {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  KitchenItemStatus get status => throw _privateConstructorUsedError; // Station
  String? get stationId => throw _privateConstructorUsedError;
  String? get stationName => throw _privateConstructorUsedError; // Seat
  int? get seatNumber => throw _privateConstructorUsedError; // Modifiers
  List<KitchenItemModifier> get modifiers =>
      throw _privateConstructorUsedError; // Special requests
  String? get specialInstructions => throw _privateConstructorUsedError;
  String? get cookingPreference => throw _privateConstructorUsedError; // Timing
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get preparedBy =>
      throw _privateConstructorUsedError; // Course: 1=Appetiser 2=Main 3=Dessert
  int? get courseNumber => throw _privateConstructorUsedError; // Display
  int? get displayOrder => throw _privateConstructorUsedError; // 86'd
  bool get is86d => throw _privateConstructorUsedError; // Void
  bool get isCancelled => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;
  DateTime? get cancelledAt =>
      throw _privateConstructorUsedError; // Edit tracking
  bool get isNewlyAdded =>
      throw _privateConstructorUsedError; // added via POS edit — highlight green
  bool get isModified =>
      throw _privateConstructorUsedError; // modifier changed — highlight amber
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this KitchenOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitchenOrderItemCopyWith<KitchenOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitchenOrderItemCopyWith<$Res> {
  factory $KitchenOrderItemCopyWith(
    KitchenOrderItem value,
    $Res Function(KitchenOrderItem) then,
  ) = _$KitchenOrderItemCopyWithImpl<$Res, KitchenOrderItem>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String productId,
    String productName,
    int quantity,
    KitchenItemStatus status,
    String? stationId,
    String? stationName,
    int? seatNumber,
    List<KitchenItemModifier> modifiers,
    String? specialInstructions,
    String? cookingPreference,
    DateTime? startedAt,
    DateTime? completedAt,
    String? preparedBy,
    int? courseNumber,
    int? displayOrder,
    bool is86d,
    bool isCancelled,
    String? cancelReason,
    DateTime? cancelledAt,
    bool isNewlyAdded,
    bool isModified,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$KitchenOrderItemCopyWithImpl<$Res, $Val extends KitchenOrderItem>
    implements $KitchenOrderItemCopyWith<$Res> {
  _$KitchenOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? status = null,
    Object? stationId = freezed,
    Object? stationName = freezed,
    Object? seatNumber = freezed,
    Object? modifiers = null,
    Object? specialInstructions = freezed,
    Object? cookingPreference = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? preparedBy = freezed,
    Object? courseNumber = freezed,
    Object? displayOrder = freezed,
    Object? is86d = null,
    Object? isCancelled = null,
    Object? cancelReason = freezed,
    Object? cancelledAt = freezed,
    Object? isNewlyAdded = null,
    Object? isModified = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as KitchenItemStatus,
            stationId: freezed == stationId
                ? _value.stationId
                : stationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            stationName: freezed == stationName
                ? _value.stationName
                : stationName // ignore: cast_nullable_to_non_nullable
                      as String?,
            seatNumber: freezed == seatNumber
                ? _value.seatNumber
                : seatNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            modifiers: null == modifiers
                ? _value.modifiers
                : modifiers // ignore: cast_nullable_to_non_nullable
                      as List<KitchenItemModifier>,
            specialInstructions: freezed == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
                      as String?,
            cookingPreference: freezed == cookingPreference
                ? _value.cookingPreference
                : cookingPreference // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            preparedBy: freezed == preparedBy
                ? _value.preparedBy
                : preparedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            courseNumber: freezed == courseNumber
                ? _value.courseNumber
                : courseNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            displayOrder: freezed == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int?,
            is86d: null == is86d
                ? _value.is86d
                : is86d // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCancelled: null == isCancelled
                ? _value.isCancelled
                : isCancelled // ignore: cast_nullable_to_non_nullable
                      as bool,
            cancelReason: freezed == cancelReason
                ? _value.cancelReason
                : cancelReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isNewlyAdded: null == isNewlyAdded
                ? _value.isNewlyAdded
                : isNewlyAdded // ignore: cast_nullable_to_non_nullable
                      as bool,
            isModified: null == isModified
                ? _value.isModified
                : isModified // ignore: cast_nullable_to_non_nullable
                      as bool,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KitchenOrderItemImplCopyWith<$Res>
    implements $KitchenOrderItemCopyWith<$Res> {
  factory _$$KitchenOrderItemImplCopyWith(
    _$KitchenOrderItemImpl value,
    $Res Function(_$KitchenOrderItemImpl) then,
  ) = __$$KitchenOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String productId,
    String productName,
    int quantity,
    KitchenItemStatus status,
    String? stationId,
    String? stationName,
    int? seatNumber,
    List<KitchenItemModifier> modifiers,
    String? specialInstructions,
    String? cookingPreference,
    DateTime? startedAt,
    DateTime? completedAt,
    String? preparedBy,
    int? courseNumber,
    int? displayOrder,
    bool is86d,
    bool isCancelled,
    String? cancelReason,
    DateTime? cancelledAt,
    bool isNewlyAdded,
    bool isModified,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$KitchenOrderItemImplCopyWithImpl<$Res>
    extends _$KitchenOrderItemCopyWithImpl<$Res, _$KitchenOrderItemImpl>
    implements _$$KitchenOrderItemImplCopyWith<$Res> {
  __$$KitchenOrderItemImplCopyWithImpl(
    _$KitchenOrderItemImpl _value,
    $Res Function(_$KitchenOrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? status = null,
    Object? stationId = freezed,
    Object? stationName = freezed,
    Object? seatNumber = freezed,
    Object? modifiers = null,
    Object? specialInstructions = freezed,
    Object? cookingPreference = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? preparedBy = freezed,
    Object? courseNumber = freezed,
    Object? displayOrder = freezed,
    Object? is86d = null,
    Object? isCancelled = null,
    Object? cancelReason = freezed,
    Object? cancelledAt = freezed,
    Object? isNewlyAdded = null,
    Object? isModified = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$KitchenOrderItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as KitchenItemStatus,
        stationId: freezed == stationId
            ? _value.stationId
            : stationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        stationName: freezed == stationName
            ? _value.stationName
            : stationName // ignore: cast_nullable_to_non_nullable
                  as String?,
        seatNumber: freezed == seatNumber
            ? _value.seatNumber
            : seatNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        modifiers: null == modifiers
            ? _value._modifiers
            : modifiers // ignore: cast_nullable_to_non_nullable
                  as List<KitchenItemModifier>,
        specialInstructions: freezed == specialInstructions
            ? _value.specialInstructions
            : specialInstructions // ignore: cast_nullable_to_non_nullable
                  as String?,
        cookingPreference: freezed == cookingPreference
            ? _value.cookingPreference
            : cookingPreference // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        preparedBy: freezed == preparedBy
            ? _value.preparedBy
            : preparedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        courseNumber: freezed == courseNumber
            ? _value.courseNumber
            : courseNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        displayOrder: freezed == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int?,
        is86d: null == is86d
            ? _value.is86d
            : is86d // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCancelled: null == isCancelled
            ? _value.isCancelled
            : isCancelled // ignore: cast_nullable_to_non_nullable
                  as bool,
        cancelReason: freezed == cancelReason
            ? _value.cancelReason
            : cancelReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isNewlyAdded: null == isNewlyAdded
            ? _value.isNewlyAdded
            : isNewlyAdded // ignore: cast_nullable_to_non_nullable
                  as bool,
        isModified: null == isModified
            ? _value.isModified
            : isModified // ignore: cast_nullable_to_non_nullable
                  as bool,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KitchenOrderItemImpl extends _KitchenOrderItem {
  const _$KitchenOrderItemImpl({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.status,
    this.stationId,
    this.stationName,
    this.seatNumber,
    final List<KitchenItemModifier> modifiers = const [],
    this.specialInstructions,
    this.cookingPreference,
    this.startedAt,
    this.completedAt,
    this.preparedBy,
    this.courseNumber,
    this.displayOrder,
    this.is86d = false,
    this.isCancelled = false,
    this.cancelReason,
    this.cancelledAt,
    this.isNewlyAdded = false,
    this.isModified = false,
    final Map<String, dynamic>? metadata,
  }) : _modifiers = modifiers,
       _metadata = metadata,
       super._();

  factory _$KitchenOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$KitchenOrderItemImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantity;
  @override
  final KitchenItemStatus status;
  // Station
  @override
  final String? stationId;
  @override
  final String? stationName;
  // Seat
  @override
  final int? seatNumber;
  // Modifiers
  final List<KitchenItemModifier> _modifiers;
  // Modifiers
  @override
  @JsonKey()
  List<KitchenItemModifier> get modifiers {
    if (_modifiers is EqualUnmodifiableListView) return _modifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modifiers);
  }

  // Special requests
  @override
  final String? specialInstructions;
  @override
  final String? cookingPreference;
  // Timing
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? preparedBy;
  // Course: 1=Appetiser 2=Main 3=Dessert
  @override
  final int? courseNumber;
  // Display
  @override
  final int? displayOrder;
  // 86'd
  @override
  @JsonKey()
  final bool is86d;
  // Void
  @override
  @JsonKey()
  final bool isCancelled;
  @override
  final String? cancelReason;
  @override
  final DateTime? cancelledAt;
  // Edit tracking
  @override
  @JsonKey()
  final bool isNewlyAdded;
  // added via POS edit — highlight green
  @override
  @JsonKey()
  final bool isModified;
  // modifier changed — highlight amber
  final Map<String, dynamic>? _metadata;
  // modifier changed — highlight amber
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'KitchenOrderItem(id: $id, orderId: $orderId, productId: $productId, productName: $productName, quantity: $quantity, status: $status, stationId: $stationId, stationName: $stationName, seatNumber: $seatNumber, modifiers: $modifiers, specialInstructions: $specialInstructions, cookingPreference: $cookingPreference, startedAt: $startedAt, completedAt: $completedAt, preparedBy: $preparedBy, courseNumber: $courseNumber, displayOrder: $displayOrder, is86d: $is86d, isCancelled: $isCancelled, cancelReason: $cancelReason, cancelledAt: $cancelledAt, isNewlyAdded: $isNewlyAdded, isModified: $isModified, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitchenOrderItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.seatNumber, seatNumber) ||
                other.seatNumber == seatNumber) &&
            const DeepCollectionEquality().equals(
              other._modifiers,
              _modifiers,
            ) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.cookingPreference, cookingPreference) ||
                other.cookingPreference == cookingPreference) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.preparedBy, preparedBy) ||
                other.preparedBy == preparedBy) &&
            (identical(other.courseNumber, courseNumber) ||
                other.courseNumber == courseNumber) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.is86d, is86d) || other.is86d == is86d) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.isNewlyAdded, isNewlyAdded) ||
                other.isNewlyAdded == isNewlyAdded) &&
            (identical(other.isModified, isModified) ||
                other.isModified == isModified) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderId,
    productId,
    productName,
    quantity,
    status,
    stationId,
    stationName,
    seatNumber,
    const DeepCollectionEquality().hash(_modifiers),
    specialInstructions,
    cookingPreference,
    startedAt,
    completedAt,
    preparedBy,
    courseNumber,
    displayOrder,
    is86d,
    isCancelled,
    cancelReason,
    cancelledAt,
    isNewlyAdded,
    isModified,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitchenOrderItemImplCopyWith<_$KitchenOrderItemImpl> get copyWith =>
      __$$KitchenOrderItemImplCopyWithImpl<_$KitchenOrderItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KitchenOrderItemImplToJson(this);
  }
}

abstract class _KitchenOrderItem extends KitchenOrderItem {
  const factory _KitchenOrderItem({
    required final String id,
    required final String orderId,
    required final String productId,
    required final String productName,
    required final int quantity,
    required final KitchenItemStatus status,
    final String? stationId,
    final String? stationName,
    final int? seatNumber,
    final List<KitchenItemModifier> modifiers,
    final String? specialInstructions,
    final String? cookingPreference,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final String? preparedBy,
    final int? courseNumber,
    final int? displayOrder,
    final bool is86d,
    final bool isCancelled,
    final String? cancelReason,
    final DateTime? cancelledAt,
    final bool isNewlyAdded,
    final bool isModified,
    final Map<String, dynamic>? metadata,
  }) = _$KitchenOrderItemImpl;
  const _KitchenOrderItem._() : super._();

  factory _KitchenOrderItem.fromJson(Map<String, dynamic> json) =
      _$KitchenOrderItemImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  KitchenItemStatus get status; // Station
  @override
  String? get stationId;
  @override
  String? get stationName; // Seat
  @override
  int? get seatNumber; // Modifiers
  @override
  List<KitchenItemModifier> get modifiers; // Special requests
  @override
  String? get specialInstructions;
  @override
  String? get cookingPreference; // Timing
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get preparedBy; // Course: 1=Appetiser 2=Main 3=Dessert
  @override
  int? get courseNumber; // Display
  @override
  int? get displayOrder; // 86'd
  @override
  bool get is86d; // Void
  @override
  bool get isCancelled;
  @override
  String? get cancelReason;
  @override
  DateTime? get cancelledAt; // Edit tracking
  @override
  bool get isNewlyAdded; // added via POS edit — highlight green
  @override
  bool get isModified; // modifier changed — highlight amber
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitchenOrderItemImplCopyWith<_$KitchenOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KitchenItemModifier _$KitchenItemModifierFromJson(Map<String, dynamic> json) {
  return _KitchenItemModifier.fromJson(json);
}

/// @nodoc
mixin _$KitchenItemModifier {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ModifierAction get action => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this KitchenItemModifier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitchenItemModifier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitchenItemModifierCopyWith<KitchenItemModifier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitchenItemModifierCopyWith<$Res> {
  factory $KitchenItemModifierCopyWith(
    KitchenItemModifier value,
    $Res Function(KitchenItemModifier) then,
  ) = _$KitchenItemModifierCopyWithImpl<$Res, KitchenItemModifier>;
  @useResult
  $Res call({String id, String name, ModifierAction action, String? notes});
}

/// @nodoc
class _$KitchenItemModifierCopyWithImpl<$Res, $Val extends KitchenItemModifier>
    implements $KitchenItemModifierCopyWith<$Res> {
  _$KitchenItemModifierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitchenItemModifier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? action = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as ModifierAction,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KitchenItemModifierImplCopyWith<$Res>
    implements $KitchenItemModifierCopyWith<$Res> {
  factory _$$KitchenItemModifierImplCopyWith(
    _$KitchenItemModifierImpl value,
    $Res Function(_$KitchenItemModifierImpl) then,
  ) = __$$KitchenItemModifierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, ModifierAction action, String? notes});
}

/// @nodoc
class __$$KitchenItemModifierImplCopyWithImpl<$Res>
    extends _$KitchenItemModifierCopyWithImpl<$Res, _$KitchenItemModifierImpl>
    implements _$$KitchenItemModifierImplCopyWith<$Res> {
  __$$KitchenItemModifierImplCopyWithImpl(
    _$KitchenItemModifierImpl _value,
    $Res Function(_$KitchenItemModifierImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KitchenItemModifier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? action = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$KitchenItemModifierImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as ModifierAction,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KitchenItemModifierImpl implements _KitchenItemModifier {
  const _$KitchenItemModifierImpl({
    required this.id,
    required this.name,
    required this.action,
    this.notes,
  });

  factory _$KitchenItemModifierImpl.fromJson(Map<String, dynamic> json) =>
      _$$KitchenItemModifierImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final ModifierAction action;
  @override
  final String? notes;

  @override
  String toString() {
    return 'KitchenItemModifier(id: $id, name: $name, action: $action, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitchenItemModifierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, action, notes);

  /// Create a copy of KitchenItemModifier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitchenItemModifierImplCopyWith<_$KitchenItemModifierImpl> get copyWith =>
      __$$KitchenItemModifierImplCopyWithImpl<_$KitchenItemModifierImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KitchenItemModifierImplToJson(this);
  }
}

abstract class _KitchenItemModifier implements KitchenItemModifier {
  const factory _KitchenItemModifier({
    required final String id,
    required final String name,
    required final ModifierAction action,
    final String? notes,
  }) = _$KitchenItemModifierImpl;

  factory _KitchenItemModifier.fromJson(Map<String, dynamic> json) =
      _$KitchenItemModifierImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  ModifierAction get action;
  @override
  String? get notes;

  /// Create a copy of KitchenItemModifier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitchenItemModifierImplCopyWith<_$KitchenItemModifierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KitchenStation _$KitchenStationFromJson(Map<String, dynamic> json) {
  return _KitchenStation.fromJson(json);
}

/// @nodoc
mixin _$KitchenStation {
  String get id => throw _privateConstructorUsedError;
  String get locationId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  KitchenStationType get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  int? get displayOrder => throw _privateConstructorUsedError;
  List<String>? get assignedStaffIds => throw _privateConstructorUsedError;
  String? get currentStaffId => throw _privateConstructorUsedError;
  String? get currentStaffName => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isPrinterEnabled => throw _privateConstructorUsedError;
  String? get printerName => throw _privateConstructorUsedError;
  List<String> get categoryIds =>
      throw _privateConstructorUsedError; // Per-station thresholds (min)
  int get urgentThresholdMins => throw _privateConstructorUsedError;
  int get veryUrgentThresholdMins => throw _privateConstructorUsedError;
  bool get autoSoundEnabled => throw _privateConstructorUsedError;
  bool get autoBumpEnabled => throw _privateConstructorUsedError;
  int? get autoBumpAfterMins => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this KitchenStation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitchenStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitchenStationCopyWith<KitchenStation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitchenStationCopyWith<$Res> {
  factory $KitchenStationCopyWith(
    KitchenStation value,
    $Res Function(KitchenStation) then,
  ) = _$KitchenStationCopyWithImpl<$Res, KitchenStation>;
  @useResult
  $Res call({
    String id,
    String locationId,
    String name,
    KitchenStationType type,
    String? description,
    String? color,
    int? displayOrder,
    List<String>? assignedStaffIds,
    String? currentStaffId,
    String? currentStaffName,
    bool isActive,
    bool isPrinterEnabled,
    String? printerName,
    List<String> categoryIds,
    int urgentThresholdMins,
    int veryUrgentThresholdMins,
    bool autoSoundEnabled,
    bool autoBumpEnabled,
    int? autoBumpAfterMins,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$KitchenStationCopyWithImpl<$Res, $Val extends KitchenStation>
    implements $KitchenStationCopyWith<$Res> {
  _$KitchenStationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitchenStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? locationId = null,
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? displayOrder = freezed,
    Object? assignedStaffIds = freezed,
    Object? currentStaffId = freezed,
    Object? currentStaffName = freezed,
    Object? isActive = null,
    Object? isPrinterEnabled = null,
    Object? printerName = freezed,
    Object? categoryIds = null,
    Object? urgentThresholdMins = null,
    Object? veryUrgentThresholdMins = null,
    Object? autoSoundEnabled = null,
    Object? autoBumpEnabled = null,
    Object? autoBumpAfterMins = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            locationId: null == locationId
                ? _value.locationId
                : locationId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as KitchenStationType,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: freezed == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int?,
            assignedStaffIds: freezed == assignedStaffIds
                ? _value.assignedStaffIds
                : assignedStaffIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            currentStaffId: freezed == currentStaffId
                ? _value.currentStaffId
                : currentStaffId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentStaffName: freezed == currentStaffName
                ? _value.currentStaffName
                : currentStaffName // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPrinterEnabled: null == isPrinterEnabled
                ? _value.isPrinterEnabled
                : isPrinterEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            printerName: freezed == printerName
                ? _value.printerName
                : printerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryIds: null == categoryIds
                ? _value.categoryIds
                : categoryIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            urgentThresholdMins: null == urgentThresholdMins
                ? _value.urgentThresholdMins
                : urgentThresholdMins // ignore: cast_nullable_to_non_nullable
                      as int,
            veryUrgentThresholdMins: null == veryUrgentThresholdMins
                ? _value.veryUrgentThresholdMins
                : veryUrgentThresholdMins // ignore: cast_nullable_to_non_nullable
                      as int,
            autoSoundEnabled: null == autoSoundEnabled
                ? _value.autoSoundEnabled
                : autoSoundEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoBumpEnabled: null == autoBumpEnabled
                ? _value.autoBumpEnabled
                : autoBumpEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoBumpAfterMins: freezed == autoBumpAfterMins
                ? _value.autoBumpAfterMins
                : autoBumpAfterMins // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KitchenStationImplCopyWith<$Res>
    implements $KitchenStationCopyWith<$Res> {
  factory _$$KitchenStationImplCopyWith(
    _$KitchenStationImpl value,
    $Res Function(_$KitchenStationImpl) then,
  ) = __$$KitchenStationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String locationId,
    String name,
    KitchenStationType type,
    String? description,
    String? color,
    int? displayOrder,
    List<String>? assignedStaffIds,
    String? currentStaffId,
    String? currentStaffName,
    bool isActive,
    bool isPrinterEnabled,
    String? printerName,
    List<String> categoryIds,
    int urgentThresholdMins,
    int veryUrgentThresholdMins,
    bool autoSoundEnabled,
    bool autoBumpEnabled,
    int? autoBumpAfterMins,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$KitchenStationImplCopyWithImpl<$Res>
    extends _$KitchenStationCopyWithImpl<$Res, _$KitchenStationImpl>
    implements _$$KitchenStationImplCopyWith<$Res> {
  __$$KitchenStationImplCopyWithImpl(
    _$KitchenStationImpl _value,
    $Res Function(_$KitchenStationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KitchenStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? locationId = null,
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? displayOrder = freezed,
    Object? assignedStaffIds = freezed,
    Object? currentStaffId = freezed,
    Object? currentStaffName = freezed,
    Object? isActive = null,
    Object? isPrinterEnabled = null,
    Object? printerName = freezed,
    Object? categoryIds = null,
    Object? urgentThresholdMins = null,
    Object? veryUrgentThresholdMins = null,
    Object? autoSoundEnabled = null,
    Object? autoBumpEnabled = null,
    Object? autoBumpAfterMins = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$KitchenStationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        locationId: null == locationId
            ? _value.locationId
            : locationId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as KitchenStationType,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: freezed == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int?,
        assignedStaffIds: freezed == assignedStaffIds
            ? _value._assignedStaffIds
            : assignedStaffIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        currentStaffId: freezed == currentStaffId
            ? _value.currentStaffId
            : currentStaffId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentStaffName: freezed == currentStaffName
            ? _value.currentStaffName
            : currentStaffName // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPrinterEnabled: null == isPrinterEnabled
            ? _value.isPrinterEnabled
            : isPrinterEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        printerName: freezed == printerName
            ? _value.printerName
            : printerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryIds: null == categoryIds
            ? _value._categoryIds
            : categoryIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        urgentThresholdMins: null == urgentThresholdMins
            ? _value.urgentThresholdMins
            : urgentThresholdMins // ignore: cast_nullable_to_non_nullable
                  as int,
        veryUrgentThresholdMins: null == veryUrgentThresholdMins
            ? _value.veryUrgentThresholdMins
            : veryUrgentThresholdMins // ignore: cast_nullable_to_non_nullable
                  as int,
        autoSoundEnabled: null == autoSoundEnabled
            ? _value.autoSoundEnabled
            : autoSoundEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoBumpEnabled: null == autoBumpEnabled
            ? _value.autoBumpEnabled
            : autoBumpEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoBumpAfterMins: freezed == autoBumpAfterMins
            ? _value.autoBumpAfterMins
            : autoBumpAfterMins // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KitchenStationImpl extends _KitchenStation {
  const _$KitchenStationImpl({
    required this.id,
    required this.locationId,
    required this.name,
    required this.type,
    this.description,
    this.color,
    this.displayOrder,
    final List<String>? assignedStaffIds,
    this.currentStaffId,
    this.currentStaffName,
    this.isActive = true,
    this.isPrinterEnabled = false,
    this.printerName,
    final List<String> categoryIds = const [],
    this.urgentThresholdMins = 8,
    this.veryUrgentThresholdMins = 15,
    this.autoSoundEnabled = false,
    this.autoBumpEnabled = false,
    this.autoBumpAfterMins,
    this.createdAt,
    this.updatedAt,
    final Map<String, dynamic>? metadata,
  }) : _assignedStaffIds = assignedStaffIds,
       _categoryIds = categoryIds,
       _metadata = metadata,
       super._();

  factory _$KitchenStationImpl.fromJson(Map<String, dynamic> json) =>
      _$$KitchenStationImplFromJson(json);

  @override
  final String id;
  @override
  final String locationId;
  @override
  final String name;
  @override
  final KitchenStationType type;
  @override
  final String? description;
  @override
  final String? color;
  @override
  final int? displayOrder;
  final List<String>? _assignedStaffIds;
  @override
  List<String>? get assignedStaffIds {
    final value = _assignedStaffIds;
    if (value == null) return null;
    if (_assignedStaffIds is EqualUnmodifiableListView)
      return _assignedStaffIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? currentStaffId;
  @override
  final String? currentStaffName;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isPrinterEnabled;
  @override
  final String? printerName;
  final List<String> _categoryIds;
  @override
  @JsonKey()
  List<String> get categoryIds {
    if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryIds);
  }

  // Per-station thresholds (min)
  @override
  @JsonKey()
  final int urgentThresholdMins;
  @override
  @JsonKey()
  final int veryUrgentThresholdMins;
  @override
  @JsonKey()
  final bool autoSoundEnabled;
  @override
  @JsonKey()
  final bool autoBumpEnabled;
  @override
  final int? autoBumpAfterMins;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'KitchenStation(id: $id, locationId: $locationId, name: $name, type: $type, description: $description, color: $color, displayOrder: $displayOrder, assignedStaffIds: $assignedStaffIds, currentStaffId: $currentStaffId, currentStaffName: $currentStaffName, isActive: $isActive, isPrinterEnabled: $isPrinterEnabled, printerName: $printerName, categoryIds: $categoryIds, urgentThresholdMins: $urgentThresholdMins, veryUrgentThresholdMins: $veryUrgentThresholdMins, autoSoundEnabled: $autoSoundEnabled, autoBumpEnabled: $autoBumpEnabled, autoBumpAfterMins: $autoBumpAfterMins, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitchenStationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            const DeepCollectionEquality().equals(
              other._assignedStaffIds,
              _assignedStaffIds,
            ) &&
            (identical(other.currentStaffId, currentStaffId) ||
                other.currentStaffId == currentStaffId) &&
            (identical(other.currentStaffName, currentStaffName) ||
                other.currentStaffName == currentStaffName) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isPrinterEnabled, isPrinterEnabled) ||
                other.isPrinterEnabled == isPrinterEnabled) &&
            (identical(other.printerName, printerName) ||
                other.printerName == printerName) &&
            const DeepCollectionEquality().equals(
              other._categoryIds,
              _categoryIds,
            ) &&
            (identical(other.urgentThresholdMins, urgentThresholdMins) ||
                other.urgentThresholdMins == urgentThresholdMins) &&
            (identical(
                  other.veryUrgentThresholdMins,
                  veryUrgentThresholdMins,
                ) ||
                other.veryUrgentThresholdMins == veryUrgentThresholdMins) &&
            (identical(other.autoSoundEnabled, autoSoundEnabled) ||
                other.autoSoundEnabled == autoSoundEnabled) &&
            (identical(other.autoBumpEnabled, autoBumpEnabled) ||
                other.autoBumpEnabled == autoBumpEnabled) &&
            (identical(other.autoBumpAfterMins, autoBumpAfterMins) ||
                other.autoBumpAfterMins == autoBumpAfterMins) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    locationId,
    name,
    type,
    description,
    color,
    displayOrder,
    const DeepCollectionEquality().hash(_assignedStaffIds),
    currentStaffId,
    currentStaffName,
    isActive,
    isPrinterEnabled,
    printerName,
    const DeepCollectionEquality().hash(_categoryIds),
    urgentThresholdMins,
    veryUrgentThresholdMins,
    autoSoundEnabled,
    autoBumpEnabled,
    autoBumpAfterMins,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of KitchenStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitchenStationImplCopyWith<_$KitchenStationImpl> get copyWith =>
      __$$KitchenStationImplCopyWithImpl<_$KitchenStationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KitchenStationImplToJson(this);
  }
}

abstract class _KitchenStation extends KitchenStation {
  const factory _KitchenStation({
    required final String id,
    required final String locationId,
    required final String name,
    required final KitchenStationType type,
    final String? description,
    final String? color,
    final int? displayOrder,
    final List<String>? assignedStaffIds,
    final String? currentStaffId,
    final String? currentStaffName,
    final bool isActive,
    final bool isPrinterEnabled,
    final String? printerName,
    final List<String> categoryIds,
    final int urgentThresholdMins,
    final int veryUrgentThresholdMins,
    final bool autoSoundEnabled,
    final bool autoBumpEnabled,
    final int? autoBumpAfterMins,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final Map<String, dynamic>? metadata,
  }) = _$KitchenStationImpl;
  const _KitchenStation._() : super._();

  factory _KitchenStation.fromJson(Map<String, dynamic> json) =
      _$KitchenStationImpl.fromJson;

  @override
  String get id;
  @override
  String get locationId;
  @override
  String get name;
  @override
  KitchenStationType get type;
  @override
  String? get description;
  @override
  String? get color;
  @override
  int? get displayOrder;
  @override
  List<String>? get assignedStaffIds;
  @override
  String? get currentStaffId;
  @override
  String? get currentStaffName;
  @override
  bool get isActive;
  @override
  bool get isPrinterEnabled;
  @override
  String? get printerName;
  @override
  List<String> get categoryIds; // Per-station thresholds (min)
  @override
  int get urgentThresholdMins;
  @override
  int get veryUrgentThresholdMins;
  @override
  bool get autoSoundEnabled;
  @override
  bool get autoBumpEnabled;
  @override
  int? get autoBumpAfterMins;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of KitchenStation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitchenStationImplCopyWith<_$KitchenStationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
