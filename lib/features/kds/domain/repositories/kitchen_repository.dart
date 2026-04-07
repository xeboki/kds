import '../models/kitchen_order.dart';

abstract class KitchenRepository {
  // ── Orders ───────────────────────────────────────────────────────────────────

  Stream<List<KitchenOrder>> watchOrders({
    required String locationId,
    String? stationId,
    KitchenOrderStatus? status,
  });

  Stream<KitchenOrder> watchOrder(String orderId);

  Future<List<KitchenOrder>> getBumpedOrders({
    required String locationId,
    int limit = 20,
  });

  // ── Order actions ─────────────────────────────────────────────────────────────

  Future<void> updateOrderStatus(String orderId, KitchenOrderStatus status);

  Future<void> bumpOrder(String orderId);

  Future<void> recallOrder(String orderId);

  Future<void> updatePriority(String orderId, KitchenOrderPriority priority);

  // ── Item actions ──────────────────────────────────────────────────────────────

  Future<void> updateItemStatus(
      String orderId, String itemId, KitchenItemStatus status);

  Future<void> markItemStarted(String orderId, String itemId);

  Future<void> markItemCompleted(String orderId, String itemId);

  Future<void> set86Item(String orderId, String itemId, {required bool is86d});

  // ── Course / Hold-and-Fire ────────────────────────────────────────────────────

  Future<void> fireCourse(String orderId, int courseNumber);

  // ── Stations ──────────────────────────────────────────────────────────────────

  Future<List<KitchenStation>> getStations(String locationId);

  Future<void> updateStation(KitchenStation station);
}
