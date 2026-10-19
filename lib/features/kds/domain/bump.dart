import 'models/kitchen_order.dart';
import 'models/screen_role.dart';

/// What a screen's bump does to a ticket.
class BumpOutcome {
  const BumpOutcome({required this.items, required this.clearsTicket});

  /// The ticket's lines after the bump.
  final List<KitchenOrderItem> items;

  /// Whether the whole ticket is now away, and leaves every screen.
  final bool clearsTicket;
}

/// Bump as one screen.
///
/// A prep station's bump means "my section is done", not "the order is away":
/// it completes the lines this screen is responsible for and leaves the rest
/// of the ticket with the sections still cooking it, and with the pass.
///
/// Before this there was one bump and it set the whole order's status, so the
/// first station to finish took the ticket off every other screen. Proven on
/// 34: STR00013, made by Bar and Fryer — one bump and neither the other
/// section nor the pass could see it again, so the food was never made.
///
/// The ticket clears when the last line in it is done, which is what a
/// one-screen kitchen has always done and stays true here. An expo screen
/// assembles the order, so its bump clears the ticket outright.
BumpOutcome bumpOutcomeFor({
  required KitchenOrder order,
  required List<String> routingCategoryIds,
  required bool isExpo,
  DateTime? at,
}) {
  if (isExpo) {
    return BumpOutcome(items: order.items, clearsTicket: true);
  }

  final now = at ?? DateTime.now();
  final items = order.items.map((item) {
    final mine = screenShowsLine(
      lineRoutingCategoryIds: item.routingCategoryIds,
      screenRoutingCategoryIds: routingCategoryIds,
      isExpo: false,
    );
    if (!mine || item.isOff || item.status == KitchenItemStatus.completed) {
      return item;
    }
    return item.copyWith(
        status: KitchenItemStatus.completed, completedAt: now);
  }).toList();

  // `isOff`, matching what the bump above skips. With `isVoided` here the
  // two disagreed: an 86'd line was passed over as not-work when completing,
  // then counted as outstanding work when deciding whether the ticket could
  // clear — so a ticket with one 86'd line stayed on the board for ever.
  final everythingDone =
      items.every((i) => i.status == KitchenItemStatus.completed || i.isOff);

  return BumpOutcome(items: items, clearsTicket: everythingDone);
}

/// Does a prep screen still show this ticket?
///
/// While it has work on it. Its own lines being done is what takes a ticket
/// off this screen — the rest stays with the sections still cooking it.
///
/// A **recalled** ticket comes back whatever state its lines are in; that is
/// the whole point of recalling one.
bool prepScreenShowsOrder(
  KitchenOrder order,
  List<String> routingCategoryIds,
) {
  bool mine(KitchenOrderItem i) => screenShowsLine(
        lineRoutingCategoryIds: i.routingCategoryIds,
        screenRoutingCategoryIds: routingCategoryIds,
        isExpo: false,
      );

  if (order.status == KitchenOrderStatus.recalled) {
    return order.items.any(mine);
  }
  return order.items.any((i) =>
      mine(i) && !i.isOff && i.status != KitchenItemStatus.completed);
}
