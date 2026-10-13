/// What a kitchen screen is for.
///
/// SPEC-097. We had `expo` as a *station type* — one more kind of station
/// alongside grill and fryer. Square and Toast both make it a property of the
/// **device**: you choose Prep or Expo when you set a screen up, and an
/// expediter screen shows the whole order while a prep screen shows only the
/// lines its section is making.
///
/// That distinction matters because the two are not the same question. A
/// station is a place in the kitchen and exists whether or not anything is
/// plugged in; a role belongs to the tablet on the wall. The pass can be a
/// station that food is routed to *and* the screen that assembles the order,
/// and with only a station type there is no way to say so.
library;

enum KdsScreenRole {
  /// Makes part of the order. Shows the lines for the station it is pinned to.
  prep('prep'),

  /// Assembles the order. Shows every line, whichever station is making it.
  expo('expo');

  const KdsScreenRole(this.wire);

  /// The value stored on the screen's record.
  final String wire;

  /// What a record says, or [prep] when it says nothing.
  ///
  /// Absent means prep: every screen registered before this field existed is
  /// one somebody pinned to a station, and reading those as expo would widen
  /// a grill board to the whole menu overnight.
  static KdsScreenRole fromWire(String? value) {
    for (final role in KdsScreenRole.values) {
      if (role.wire == value) return role;
    }
    return KdsScreenRole.prep;
  }
}

/// The station a board should filter by, given what this screen is.
///
/// This is the whole rule, in one place, because it is the kind of thing that
/// otherwise gets re-derived slightly differently in the query, the card and
/// the header — and a board that filters its orders by one answer and its
/// lines by another shows a ticket with nothing on it.
///
/// Expo ignores its pin entirely: an expediter pinned to the pass still has to
/// see the grill's lines, or it cannot tell when the order is complete.
String? stationFilterFor(KdsScreenRole role, String? stationId) {
  if (role == KdsScreenRole.expo) return null;
  if (stationId == null || stationId.isEmpty) return null;
  return stationId;
}
