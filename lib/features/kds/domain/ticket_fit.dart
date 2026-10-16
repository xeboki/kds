import 'models/kitchen_order.dart';

/// How a ticket's rows are spent when the board gives it a fixed row budget.
///
/// The board draws every ticket in a slot it sized in advance, and the card
/// may not scroll — so the card and the board have to agree, to the row, on
/// what a ticket costs. They agree by both going through here.
///
/// A course heading is a row. Nothing else on the board charged for one, which
/// is how a coursed ticket came to be drawn past the bottom of its slot and
/// clipped, with a footer that said nothing was hidden (SPEC-097).
class TicketFit {
  const TicketFit({
    required this.perCourseShown,
    required this.itemsShown,
    required this.itemsHidden,
  });

  /// Course number → how many of its lines the card may draw, in order.
  final Map<int, int> perCourseShown;

  final int itemsShown;

  /// Lines, never heading rows. It is quoted to a cook as "+N more", so it
  /// counts the things a cook would have to cook.
  final int itemsHidden;

  bool get hidesAnything => itemsHidden > 0;
}

/// Rows a ticket needs to be drawn whole: one per line, plus one per course
/// heading once there is more than one course to head.
int rowsNeeded(Map<int, List<KitchenOrderItem>> byCourse) {
  final items = byCourse.values.fold<int>(0, (sum, l) => sum + l.length);
  return byCourse.length > 1 ? items + byCourse.length : items;
}

/// Decide what fits. A null [rowBudget] means the surface may draw it whole —
/// the ticket sheet, which is the one place allowed to scroll.
TicketFit fitTicket(
  Map<int, List<KitchenOrderItem>> byCourse, {
  required int? rowBudget,
}) {
  final courses = byCourse.keys.toList()..sort();
  final totalItems = byCourse.values.fold<int>(0, (sum, l) => sum + l.length);
  final whole = {
    for (final c in courses) c: byCourse[c]!.length,
  };

  if (rowBudget == null || rowsNeeded(byCourse) <= rowBudget) {
    return TicketFit(
      perCourseShown: whole,
      itemsShown: totalItems,
      itemsHidden: 0,
    );
  }

  // Something will be hidden, so one row is spent saying so. Without it the
  // notice pushes the last line out of a clipped box and the count it quotes
  // is one too few — a number that is wrong only when it matters.
  var rows = rowBudget - 1;
  final headed = courses.length > 1;
  final shown = <int, int>{};
  var shownItems = 0;

  for (final course in courses) {
    final heading = headed ? 1 : 0;
    // A heading with none of its lines under it wastes the row it costs.
    if (rows < heading + 1) break;
    rows -= heading;
    final take = byCourse[course]!.length < rows
        ? byCourse[course]!.length
        : rows;
    shown[course] = take;
    shownItems += take;
    rows -= take;
    if (rows <= 0) break;
  }

  return TicketFit(
    perCourseShown: shown,
    itemsShown: shownItems,
    itemsHidden: totalItems - shownItems,
  );
}
