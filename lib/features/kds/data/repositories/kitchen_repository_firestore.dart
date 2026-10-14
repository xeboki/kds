import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_init_service.dart';
import '../../domain/models/kitchen_order.dart';
import '../../domain/models/screen_role.dart';
import '../../domain/repositories/kitchen_repository.dart';

class KitchenRepositoryFirestore implements KitchenRepository {
  /// Pass an explicit [db] for testing; otherwise uses the singleton
  /// [FirebaseInitService] instance that was initialised after login.
  KitchenRepositoryFirestore([FirebaseFirestore? db])
      : _db = db ?? FirebaseInitService().firestore!;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('kitchen_orders');

  CollectionReference<Map<String, dynamic>> get _stations =>
      _db.collection('kitchen_stations');

  // ── Orders ────────────────────────────────────────────────────────────────────

  @override
  Stream<List<KitchenOrder>> watchOrders({
    required String locationId,
    List<String> routingCategoryIds = const [],
    bool isExpo = false,
    KitchenOrderStatus? status,
  }) {
    var query = _orders
        .where('location_id', isEqualTo: locationId)
        .where('status', whereIn: KitchenOrderStatus.values
            .where((s) => s.isActive)
            .map((s) => s.name)
            .toList())
        .orderBy('order_time');

    return query.snapshots().map((snap) {
      var orders = snap.docs
          .map((d) => KitchenOrder.fromJson({...d.data(), 'id': d.id}))
          .toList();

      // SPEC-097. An order reaches this screen when any of its lines does.
      // Decided by `screenShowsLine` rather than restated here, so the order
      // filter and the line filter cannot disagree — a board that admits a
      // ticket and then renders none of its lines shows an empty card.
      if (!isExpo) {
        orders = orders
            .where((o) => o.items.any((i) => screenShowsLine(
                  lineRoutingCategoryIds: i.routingCategoryIds,
                  screenRoutingCategoryIds: routingCategoryIds,
                  isExpo: false,
                )))
            .toList();
      }
      if (status != null) {
        orders = orders.where((o) => o.status == status).toList();
      }
      return orders;
    });
  }

  @override
  Stream<KitchenOrder> watchOrder(String orderId) {
    return _orders.doc(orderId).snapshots().map(
        (d) => KitchenOrder.fromJson({...d.data()!, 'id': d.id}));
  }

  @override
  Future<List<KitchenOrder>> getBumpedOrders({
    required String locationId,
    int limit = 20,
  }) async {
    final snap = await _orders
        .where('location_id', isEqualTo: locationId)
        .where('status', isEqualTo: KitchenOrderStatus.bumped.name)
        .orderBy('bumped_at', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => KitchenOrder.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  // ── Order actions ─────────────────────────────────────────────────────────────

  @override
  Future<void> updateOrderStatus(
      String orderId, KitchenOrderStatus status) async {
    final data = <String, dynamic>{'status': status.name};
    final now = FieldValue.serverTimestamp();
    switch (status) {
      case KitchenOrderStatus.preparing:
        data['started_at'] = now;
        break;
      case KitchenOrderStatus.ready:
        data['ready_at'] = now;
        break;
      case KitchenOrderStatus.bumped:
        data['bumped_at'] = now;
        break;
      case KitchenOrderStatus.served:
        data['served_at'] = now;
        break;
      case KitchenOrderStatus.recalled:
        data['recalled_at'] = now;
        break;
      default:
        break;
    }
    await _orders.doc(orderId).update(data);
  }

  @override
  Future<void> bumpOrder(String orderId) =>
      updateOrderStatus(orderId, KitchenOrderStatus.bumped);

  @override
  Future<void> recallOrder(String orderId) =>
      updateOrderStatus(orderId, KitchenOrderStatus.recalled);

  @override
  Future<void> updatePriority(
      String orderId, KitchenOrderPriority priority) async {
    await _orders.doc(orderId).update({'priority': priority.name});
  }

  // ── Item actions ──────────────────────────────────────────────────────────────

  @override
  Future<void> updateItemStatus(
      String orderId, String itemId, KitchenItemStatus status) async {
    final orderDoc = await _orders.doc(orderId).get();
    if (!orderDoc.exists) return;
    final order =
        KitchenOrder.fromJson({...orderDoc.data()!, 'id': orderDoc.id});

    final updatedItems = order.items.map((item) {
      if (item.id != itemId) return item;
      final now = DateTime.now();
      return item.copyWith(
        status: status,
        startedAt: status == KitchenItemStatus.preparing ? now : item.startedAt,
        completedAt:
            status == KitchenItemStatus.completed ? now : item.completedAt,
      );
    }).toList();

    final allDone = updatedItems.every((i) =>
        i.status == KitchenItemStatus.completed ||
        i.status == KitchenItemStatus.cancelled);

    final update = <String, dynamic>{
      'items': updatedItems.map((i) => i.toJson()).toList(),
    };
    if (allDone) {
      update['status'] = KitchenOrderStatus.ready.name;
      update['ready_at'] = FieldValue.serverTimestamp();
    }
    await _orders.doc(orderId).update(update);
  }

  @override
  Future<void> markItemStarted(String orderId, String itemId) =>
      updateItemStatus(orderId, itemId, KitchenItemStatus.preparing);

  @override
  Future<void> markItemCompleted(String orderId, String itemId) =>
      updateItemStatus(orderId, itemId, KitchenItemStatus.completed);

  @override
  Future<void> set86Item(
      String orderId, String itemId, {required bool is86d}) async {
    final orderDoc = await _orders.doc(orderId).get();
    if (!orderDoc.exists) return;
    final order =
        KitchenOrder.fromJson({...orderDoc.data()!, 'id': orderDoc.id});
    final updatedItems = order.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(is86d: is86d);
    }).toList();
    await _orders.doc(orderId).update({
      'items': updatedItems.map((i) => i.toJson()).toList(),
    });
  }

  // ── Course / Hold-and-Fire ────────────────────────────────────────────────────

  @override
  Future<void> fireCourse(String orderId, int courseNumber) async {
    final orderDoc = await _orders.doc(orderId).get();
    if (!orderDoc.exists) return;
    final order =
        KitchenOrder.fromJson({...orderDoc.data()!, 'id': orderDoc.id});
    final updatedItems = order.items.map((item) {
      if ((item.courseNumber ?? 1) == courseNumber &&
          item.status == KitchenItemStatus.held) {
        return item.copyWith(status: KitchenItemStatus.pending);
      }
      return item;
    }).toList();
    await _orders.doc(orderId).update({
      'items': updatedItems.map((i) => i.toJson()).toList(),
    });
  }

  // ── Stations ──────────────────────────────────────────────────────────────────

  @override
  Future<List<KitchenStation>> getStations(String locationId) async {
    final snap = await _stations
        .where('location_id', isEqualTo: locationId)
        .where('is_active', isEqualTo: true)
        .orderBy('display_order')
        .get();
    return snap.docs
        .map((d) => KitchenStation.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  @override
  Future<void> updateStation(KitchenStation station) async {
    final data = station.toJson();
    data.remove('id');
    await _stations.doc(station.id).update(data);
  }
}
