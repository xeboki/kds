/// Fitting a service onto a screen without scrolling it.
///
/// A kitchen screen is read at a glance, from two metres away, by someone
/// holding a pan. Scrolling is the wrong verb for it twice over: the board had
/// a page scroll *and* every ticket had its own inner scroll, so finding the
/// fourth line of the eleventh order meant two gestures in two nested
/// surfaces, with greasy hands, while the thing you were looking for moved.
///
/// Nobody good does that. Toast's KDS shows a fixed maximum number of tickets
/// per screen and **paginates**, with page indicators you can tap; a long
/// ticket expands across several grid slots rather than scrolling inside its
/// own box. Square's rail and tile layouts page too — and their own forums
/// carry the warning for the other approach: a moderator's advice for long
/// tickets is to switch to a layout that "will require that you scroll longer
/// tickets", and users report a second page of a long order that cannot be
/// reached at all.
///
/// So: no scrolling anywhere. The board is a fixed grid of slots, a ticket
/// takes as many vertical slots as its lines need, and what does not fit goes
/// on the next page.
library;

import '../../domain/models/kitchen_order.dart';
import '../../domain/ticket_fit.dart';

/// One line of a ticket, in logical pixels, at each ticket size.
///
/// Real measurements of `ItemTile`, not a share of the viewport. The first
/// version divided the column height into fifteen equal "line-heights" and
/// called each one a line — they came out at 37px against a real 42, so the
/// budget promised room for a line the card then cropped, silently, with no
/// count to say it had. A board that quietly drops a line is worse than one
/// that scrolls.
const kLinePx = <int, double>{0: 36, 1: 42, 2: 50};

/// Header and bump footer, in logical pixels.
///
/// Flat across the three sizes because neither scales with them: the header
/// carries an order number, chips and icons, and the bump button is a fixed
/// 38 high. Only the item lines grow.
///
/// Counts the card's own vertical padding around the item list as well as the
/// header and footer. Leaving it out was worth about a third of a line, which
/// is nothing until a ticket has six.
const kChromePx = 122.0;

/// The gap below a card, charged to the card above it.
///
/// Charged, not subtracted afterwards. Taking it off the height at render
/// time made every card exactly one gap shorter than the lines it had been
/// given room for — invisible at medium, where the rounding happened to
/// absorb it, and a cropped line at small with no count to say so.
const kCardGapPx = 10.0;

/// Header, footer and the gap, expressed in lines — how a ticket is costed.
int chromeInLines(int size) =>
    ((kChromePx + kCardGapPx) / kLinePx[size]!).ceil();

/// Lines a column of [height] can carry at this ticket size.
///
/// Derived from the screen rather than from a setting: the board holds what
/// the board holds, and a number somebody typed cannot change that. The size
/// setting changes how big a line is, which is the thing a kitchen actually
/// wants to choose — the same control Toast offers as Small / Medium / Large.
int columnCapacity(double height, int size) =>
    (height / kLinePx[size]!).floor().clamp(4, 100);

/// What a ticket costs a column, in line-heights, capped at a whole column.
///
/// Costed in lines rather than rounded up to whole rows. Rounding looked
/// tidier and packed badly: a six-line ticket claimed two rows of three and
/// left a row that only a two-line ticket could use, so a page carried three
/// tickets and two visible gaps. Charging the real cost lets a long ticket and
/// a short one share a column exactly as they fit.
///
/// Capped because the alternative is worse than truncating: a ticket taller
/// than the screen either scrolls — the thing this exists to remove — or
/// spills onto a page that, in Square's case, users report being unable to
/// reach at all. A ticket at the cap says how many lines it holds, and the
/// expo screen is where the whole order is read.
int costOf(KitchenOrder order, {
  required List<String> screenRoutingCategoryIds,
  required bool isExpo,
  required int capacity,
  required int size,
}) {
  // Rows, not lines: a coursed ticket also pays for its course headings, and
  // the card budgets through the same function so the two cannot disagree.
  final rows = rowsNeeded(
      order.coursesFor(screenRoutingCategoryIds, isExpo: isExpo));
  return (rows + chromeInLines(size)).clamp(1, capacity);
}

/// One page of the board: the tickets on it, in the order they are read.
class BoardPage {
  const BoardPage(this.columns);

  /// Column-major. Reading down a column, then across, is oldest-first.
  final List<List<KitchenOrder>> columns;

  bool get isEmpty => columns.every((c) => c.isEmpty);
}

/// Pack units into pages of columns, oldest first.
///
/// Generic over what a unit is, because the board shows the same service two
/// ways: as tickets, and as tables with their tickets under them. Two packers
/// would drift, and the one that drifted would be the one nobody was looking
/// at during a service.
///
/// Fills a column top to bottom, then the next, then starts a page — so the
/// oldest unit is top-left and the newest last, which is the order a cook
/// works in. A unit never moves because something behind it was bumped, only
/// because something in front of it was.
List<List<List<T>>> packColumns<T>(
  List<T> units, {
  required int columns,
  required int capacity,
  required int Function(T) cost,
}) {
  final pages = <List<List<T>>>[];
  var current = List.generate(columns, (_) => <T>[]);
  var used = List.filled(columns, 0);

  void startPage() {
    pages.add(current);
    current = List.generate(columns, (_) => <T>[]);
    used = List.filled(columns, 0);
  }

  for (final unit in units) {
    final need = cost(unit).clamp(1, capacity);

    // First column with room, scanned from the left every time.
    //
    // A cursor that only moved forward looked right and packed terribly: one
    // tall unit in column three sent everything after it to a new page, and a
    // twenty-five ticket service spread over eight near-empty pages with two
    // columns of whitespace on each.
    var col = 0;
    while (col < columns && used[col] + need > capacity) {
      col++;
    }
    if (col >= columns) {
      startPage();
      col = 0;
    }
    current[col].add(unit);
    used[col] += need;
  }

  if (current.any((c) => c.isNotEmpty) || pages.isEmpty) {
    pages.add(current);
  }
  return pages;
}

/// Pack tickets into pages of [columns], each holding [capacity] lines.
List<BoardPage> paginate(
  List<KitchenOrder> orders, {
  required int columns,
  required int capacity,
  required int size,
  required List<String> screenRoutingCategoryIds,
  required bool isExpo,
}) =>
    packColumns<KitchenOrder>(
      orders,
      columns: columns,
      capacity: capacity,
      cost: (o) => costOf(o,
          screenRoutingCategoryIds: screenRoutingCategoryIds,
          isExpo: isExpo,
          capacity: capacity,
          size: size),
    ).map(BoardPage.new).toList();

/// Deal a ranked list into pages of balanced columns.
///
/// Each page takes as many as fit, then shares them evenly so no column is
/// much longer than its neighbour. Reading order is preserved: down a column,
/// then across, so the biggest number is still top-left.
List<List<List<T>>> balanceIntoPages<T>(
  List<T> items, {
  required int columns,
  required int perColumn,
}) {
  final pages = <List<List<T>>>[];
  final pageSize = columns * perColumn;
  for (var start = 0; start < items.length || pages.isEmpty; start += pageSize) {
    final slice = items.sublist(
        start, (start + pageSize).clamp(0, items.length));
    final height = (slice.length / columns).ceil().clamp(1, perColumn);
    pages.add([
      for (var c = 0; c < columns; c++)
        slice.sublist(
          (c * height).clamp(0, slice.length),
          ((c + 1) * height).clamp(0, slice.length),
        ),
    ]);
    if (slice.isEmpty) break;
  }
  return pages;
}
