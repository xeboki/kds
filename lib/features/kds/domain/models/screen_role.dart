/// What a kitchen screen is, and what it therefore shows.
///
/// SPEC-097, Square's model and its naming. A screen is set up as a **Prep
/// station** or an **Expo station**, and a prep screen switches on the
/// *kitchen routing categories* it wants to show. Nothing is pinned to
/// anything: a screen can show several categories, two screens can show the
/// same one, and re-pointing a tablet rewrites no tickets.
///
/// Both are properties of the registered screen, set in the back office, not
/// chosen on the device — so replacing the hardware keeps them, and a cook
/// cannot turn the grill screen into the pass by leaning on it.
library;

enum KdsScreenRole {
  /// Makes part of the order. Shows the routing categories it is switched on
  /// for, plus anything nobody claimed.
  prep('prep'),

  /// Assembles the order. Shows every line, whichever part of the kitchen is
  /// making it.
  expo('expo');

  const KdsScreenRole(this.wire);

  /// The value stored on the screen's record.
  final String wire;

  /// What a record says, or [prep] when it says nothing.
  ///
  /// Absent means prep: every screen registered before this field existed is
  /// one somebody set up to show part of the kitchen, and reading those as
  /// expo would widen a grill board to the whole menu overnight.
  static KdsScreenRole fromWire(String? value) {
    for (final role in KdsScreenRole.values) {
      if (role.wire == value) return role;
    }
    return KdsScreenRole.prep;
  }
}

/// Does this screen show this line?
///
/// The whole display rule, in one place, so the query, the card and the header
/// cannot answer it three slightly different ways — a board that filters its
/// orders by one answer and its lines by another shows a ticket with nothing
/// on it.
///
///   * An **expo** screen shows everything. It assembles the order, so it has
///     to see every line whichever part of the kitchen is making it.
///   * A **prep** screen shows the routing categories it is switched on for,
///     **plus anything nobody claimed**.
///
/// That second half is the rule that stops food being lost. A line in no
/// routing category at all appears on every prep screen rather than none: the
/// opposite default is silent — it shows up nowhere, nothing errors, and the
/// first anybody knows is a customer asking where their order went.
///
/// This mirrors `API/services/kitchen_routing.py::screen_shows`, and the two
/// are held together by `API/tests/fixtures/kitchen_routing_cases.json`, which
/// both test suites read.
bool screenShowsLine({
  required List<String> lineRoutingCategoryIds,
  required List<String> screenRoutingCategoryIds,
  required bool isExpo,
}) {
  if (isExpo) return true;
  if (lineRoutingCategoryIds.isEmpty) return true;
  return screenRoutingCategoryIds.any(lineRoutingCategoryIds.contains);
}
