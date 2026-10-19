/// A line the board hides must be reachable from the board.
///
/// For one build the card truncated a long ticket to "+5 more — open on the
/// pass", which named five lines and gave a cook no way to read them. "Open
/// on the pass" is an instruction to walk to another screen mid-service, and
/// it assumes an expo screen the kitchen may never have set up.
///
/// That is the same fault Square's own sellers report in rail mode — part of
/// an order on a page that cannot be reached — arrived at from the other
/// direction. Truncating is only acceptable while there is a way in.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('the truncation notice opens the ticket', () {
    final card = _read('lib/features/kds/presentation/widgets/order_card.dart');

    // The notice has to be inside something tappable that opens the sheet.
    final noticeAt = card.indexOf(r"'+$hiddenLines more'");
    expect(noticeAt, greaterThan(-1),
        reason: 'the truncation notice has moved or gone');

    // Walk back to the widget that wraps it and check it is an InkWell with
    // an onTap — a Text on its own is the bug this file exists for.
    final before = card.substring(0, noticeAt);
    final wrapAt = before.lastIndexOf('InkWell(');
    expect(wrapAt, greaterThan(-1),
        reason: 'the "+N more" notice is not inside anything tappable');
    // The handler has to lead somewhere. `onTap:` on its own passed this
    // test with `onTap: null` wired underneath it — a tap target that opens
    // nothing, which is the exact fault in a different costume.
    final handler = RegExp(r'onTap:\s*([^,\n]+)')
        .firstMatch(before.substring(wrapAt))
        ?.group(1)
        ?.trim();
    expect(handler, isNotNull,
        reason: 'the "+N more" notice is not tappable');
    expect(handler, isNot('null'),
        reason: 'the "+N more" notice is tappable and opens nothing');

    // And what it leads to has to be the sheet.
    expect(card, contains('showTicketSheet('),
        reason: 'nothing on the card opens the full ticket');
  });

  test('it no longer sends anybody to another screen', () {
    final card = _read('lib/features/kds/presentation/widgets/order_card.dart');
    expect(card, isNot(contains('open on the pass')),
        reason: 'the card still tells a cook to walk to the expo screen');
  });

  test('the sheet shows every line, not the budgeted ones', () {
    final sheet =
        _read('lib/features/kds/presentation/widgets/ticket_sheet.dart');
    // It must render from the full `linesFor` list with no cap applied —
    // a sheet that truncated too would leave the lines unreachable again.
    expect(sheet, contains('linesFor('));
    expect(sheet, isNot(contains('maxLines')),
        reason: 'the full-ticket sheet is applying a line budget of its own');
    expect(sheet, isNot(contains('.take(')),
        reason: 'the full-ticket sheet is dropping lines');
  });

  test('a line can still be worked from the sheet', () {
    // Opening a ticket to read it and then not being able to start or
    // complete a line from there would send the cook back to the card.
    final sheet =
        _read('lib/features/kds/presentation/widgets/ticket_sheet.dart');
    for (final action in ['markItemStarted', 'markItemCompleted', 'set86Item',
        'bumpForScreen']) {
      expect(sheet, contains(action), reason: '$action is not reachable here');
    }
  });
}
