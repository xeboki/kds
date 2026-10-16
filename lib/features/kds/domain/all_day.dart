/// How much of each thing the kitchen still has to make.
///
/// The "all day" count, which is what Square and Toast put in front of a cook
/// and what this board was missing. Square describes it as "a count of a
/// particular item across all tickets in the queue that require preparation";
/// Toast's all-day view shows a total per item; Tabit's is "the items to be
/// sold within all of the tickets currently displayed".
///
/// None of them headline the number of open orders, and that is the point.
/// "Twenty-five orders in the queue" is not a thing a cook can act on. "Twelve
/// flat whites" is: you pull twelve cups and make them together, which is the
/// difference between a service that flows and one that goes out cold.
///
/// Square does not even have an in-progress order state to count — sellers
/// have asked for one and it does not exist. Tickets are open or completed.
library;

import 'models/kitchen_order.dart';

/// One product, and how many of it are outstanding.
class AllDayLine {
  const AllDayLine({
    required this.productName,
    required this.quantity,
    required this.ticketCount,
  });

  final String productName;

  /// Units still to make, summed across every open ticket.
  final int quantity;

  /// How many tickets they are spread over, so a cook can tell twelve
  /// coffees on one party's order from twelve on twelve tables.
  final int ticketCount;
}

/// Outstanding work across the orders on this screen, biggest first.
///
/// Counts only what is still to be made: a line already marked done, or 86'd,
/// or cancelled is not work. Counting those would inflate the number a cook
/// is pulling stock against, which is worse than not showing it at all.
List<AllDayLine> allDayCounts(
  List<KitchenOrder> orders, {
  required List<String> screenRoutingCategoryIds,
  required bool isExpo,
}) {
  final quantities = <String, int>{};
  final tickets = <String, Set<String>>{};

  for (final order in orders) {
    for (final item
        in order.linesFor(screenRoutingCategoryIds, isExpo: isExpo)) {
      if (item.is86d ||
          item.status == KitchenItemStatus.completed ||
          item.status == KitchenItemStatus.cancelled) {
        continue;
      }
      final name = item.productName;
      quantities[name] = (quantities[name] ?? 0) + item.quantity;
      tickets.putIfAbsent(name, () => <String>{}).add(order.id);
    }
  }

  final lines = quantities.entries
      .map((e) => AllDayLine(
            productName: e.key,
            quantity: e.value,
            ticketCount: tickets[e.key]!.length,
          ))
      .toList()
    // Most outstanding first — that is the order a cook batches in. Ties go
    // alphabetically so the list does not reshuffle itself between reads.
    ..sort((a, b) {
      final byQuantity = b.quantity.compareTo(a.quantity);
      return byQuantity != 0
          ? byQuantity
          : a.productName.toLowerCase().compareTo(b.productName.toLowerCase());
    });

  return lines;
}
