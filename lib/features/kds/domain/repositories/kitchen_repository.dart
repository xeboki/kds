import '../models/kitchen_order.dart';

abstract class KitchenRepository {
  // ── Orders ───────────────────────────────────────────────────────────────────

  Stream<List<KitchenOrder>> watchOrders({
    required String locationId,
    List<String> routingCategoryIds,
    bool isExpo,
    KitchenOrderStatus? status,
  });

  Stream<KitchenOrder> watchOrder(String orderId);

  /// Recently bumped tickets, newest first.
  ///
  /// [limit] is the *recall list's* page, not a figure anyone counts. The
  /// analytics panel asks for a bigger one: at 20 its "bumped in the last
  /// hour" silently stopped counting at 20 on any service busy enough for
  /// the number to matter.
  Future<List<KitchenOrder>> getBumpedOrders({
    required String locationId,
    int limit = 20,
  });

  // ── Order actions ─────────────────────────────────────────────────────────────

  Future<void> updateOrderStatus(String orderId, KitchenOrderStatus status);

  /// Bump as **this screen**.
  ///
  /// A prep station's bump means "my section is done", not "the order is
  /// away" — it completes the lines this screen is responsible for and
  /// leaves the rest of the ticket on the sections still cooking it. Only
  /// when the last line in the order is done does the ticket clear.
  ///
  /// Before this there was one bump and it set the whole order's status, so
  /// on a two-section ticket the first station to finish took the ticket off
  /// every other screen and off the pass. Proven on 34: STR00013, made by
  /// Bar and Fryer — one bump and neither section nor the pass could see it
  /// again.
  ///
  /// An expo screen assembles the order, so its bump clears the ticket. That
  /// is the *only* way to clear one: the whole-order bump is no longer on
  /// this interface, because leaving it there leaves the footgun loaded.
  Future<void> bumpForScreen(
    String orderId, {
    required List<String> routingCategoryIds,
    required bool isExpo,
  });

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
