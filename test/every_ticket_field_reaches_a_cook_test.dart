import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// A field the wire carries, the model parses, and no screen draws is a fact
/// the kitchen was told and never shown.
///
/// `scheduledFor` was exactly that: parsed, converted, used nowhere, so a
/// pre-order rang in on Thursday for Saturday night sat on the board counting
/// up and went red within 20 minutes. Found only by listing the model's
/// fields against the presentation layer, which is what this does.
///
/// **Opt-out, not opt-in.** A new field is covered the moment it is added;
/// a field that genuinely never belongs on a screen has to be named here
/// with a reason, which is a decision someone has to write down.
void main() {
  /// Fields that are plumbing, not something a cook reads.
  const notForScreens = <String, String>{
    'id': 'the document key',
    'orderId': 'the document key of the parent',
    'productId': 'the catalogue key behind productName',
    'serverId': 'the key behind serverName, which is drawn',
    'stationId': 'the key behind stationName',
    'locationId': 'tenancy',
    'metadata': 'an open bag with no agreed contents to draw',
    'assignedStations': 'routing input; routingCategoryIds is what filters',
    'routingCategoryIds': 'the filter itself — it decides what is drawn',
    'isUnclaimed': 'drives the unclaimed styling rather than being printed',
    'preparedBy': 'recorded for reporting, not read back at the pass',
    'servedAt': 'front-of-house timestamp, after the kitchen is done',
    'recalledAt': 'drives the recall list membership, not a label',
    'stationName': 'the routing-category chip already says where it is made',
    'seatCount': "the table's capacity, not this party — guestCount is drawn",
    'startedAt': 'reporting; the line\'s status is what a cook reads',
    'completedAt': 'reporting; the line\'s status is what a cook reads',
    'readyAt': 'reporting; the ticket turns ready on its status',
    'cancelledAt': 'the VOID badge says it is off; the clock time adds nothing',
    'displayOrder': 'sorts the lines in linesFor rather than being printed',
  };

  /// Fields a screen reaches through a model member instead of by name.
  ///
  /// Named rather than sniffed out: an earlier version of this guard tried to
  /// follow the indirection with a regex over the model, and it passed with
  /// `scheduledFor` drawn nowhere — it was pulling in member bodies it had no
  /// business matching. The member here is checked to be called from a screen,
  /// so the chain is proven rather than assumed.
  const drawnVia = <String, String>{
    'courseNumber': 'coursesFor',
    // The void flag is read through `isVoided`, which folds it together with
    // the cancelled status — the two meanings of "nobody will cook this"
    // that used to be checked in different places.
    'isCancelled': 'isVoided',
  };

  late List<String> fields;
  late String presentation;

  setUpAll(() {
    final model =
        File('lib/features/kds/domain/models/kitchen_order.dart')
            .readAsStringSync();

    // Only the two ticket factories. The file also holds enums and the
    // station/table models, and sweeping the whole of it had the guard
    // demanding a screen for `fryer` and `displayOrder`.
    String factoryBody(String name) {
      final start = model.indexOf('const factory $name({');
      expect(start, greaterThan(-1), reason: 'no $name factory any more');
      final end = model.indexOf('}) = _$name;', start);
      expect(end, greaterThan(start), reason: '$name factory did not close');
      return model.substring(start, end);
    }

    final re = RegExp(
      r'^\s*(?:@\w+(?:\([^)]*\))?\s+)*(?:required\s+)?[\w<>, ?]+\s+(\w+),\s*$',
      multiLine: true,
    );
    fields = [factoryBody('KitchenOrder'), factoryBody('KitchenOrderItem')]
        .expand((body) => re.allMatches(body).map((m) => m.group(1)!))
        .toSet()
        .toList()
      ..sort();

    presentation = Directory('lib/features/kds/presentation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    // The domain layer may also render — the printed kitchen ticket is a
    // surface a cook reads, so it counts.
    presentation +=
        File('lib/features/kds/domain/printing/kitchen_ticket_pdf.dart')
            .readAsStringSync();

    // `this.x` is a constructor parameter being declared, not a ticket field
    // being drawn. Left in, `_ScheduledChip(this.scheduledFor)` stood in for
    // a render and the guard passed with the chip deleted from the card.
    presentation = presentation.replaceAll('this.', 'DECLARES_');

  });

  test('the model actually parsed — the regex still matches fields', () {
    // Without this the guard passes by finding nothing to check.
    expect(fields.length, greaterThan(20),
        reason: 'only found $fields — the field regex has gone stale');
    expect(fields, containsAll(['scheduledFor', 'serverName', 'seatNumber']));
  });

  test('every ticket field a cook needs is drawn on some surface', () {
    final unrendered = <String>[];
    for (final field in fields) {
      if (notForScreens.containsKey(field)) continue;
      // A getter built on the field counts: `dueAt` is how scheduledFor and
      // orderTime reach the timer.
      // A **member access**, not the bare name. `_ScheduledChip` declares its
      // own parameter `scheduledFor`, and matching the bare identifier let
      // that declaration stand in for a render: the guard passed with the
      // chip removed from the card and the due line removed from the sheet.
      bool reached(String name) =>
          RegExp(r'\.' + name + r'\b').hasMatch(presentation);
      final member = drawnVia[field];
      if (!reached(field) && !(member != null && reached(member))) {
        unrendered.add(field);
      }
    }
    expect(unrendered, isEmpty,
        reason: 'carried on the ticket and drawn nowhere: '
            '${unrendered.join(', ')}. Draw it, or name it in notForScreens '
            'with the reason it never belongs on a screen.');
  });

  test('nothing is opted out or redirected that no longer exists', () {
    // An opt-out for a deleted field hides the next field to take its name.
    final stale = [...notForScreens.keys, ...drawnVia.keys]
        .where((f) => !fields.contains(f))
        .toList();
    expect(stale, isEmpty,
        reason: 'opted out but not a field any more: ${stale.join(', ')}');
  });
}
