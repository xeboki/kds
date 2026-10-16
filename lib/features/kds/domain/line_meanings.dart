import 'models/kitchen_order.dart';

/// What a dot, a badge or a timer colour means, in words.
///
/// One source, read by both the legend sheet and the hover tooltips on the
/// board. Written twice they drift, and a legend that disagrees with the
/// screen is worse than no legend.
String statusMeaning(KitchenItemStatus status) => switch (status) {
      KitchenItemStatus.pending => 'Not started yet',
      KitchenItemStatus.preparing => 'Being cooked — someone has started it',
      KitchenItemStatus.completed => 'Done — crossed out and faded back',
      KitchenItemStatus.held =>
        'Held for its course — not to be cooked yet',
      KitchenItemStatus.cancelled => 'Cancelled',
    };

const String eightySixMeaning =
    "86'd — the kitchen has run out. Long-press the line, or use the 86 "
    'button on the open ticket, to clear it';

const String voidMeaning =
    'Voided — the server took it off the order. Do not cook it; open the '
    'ticket to see the reason given';

const String newlyAddedMeaning =
    'Added to a ticket that was already in the kitchen';

const String modifiedMeaning =
    'Its modifiers changed after it was sent — read it again';

/// What the ticket timer is saying, given this screen's own rungs.
String timerMeaning({
  required int minutes,
  required bool countingDown,
  required int urgentMins,
  required int veryUrgentMins,
}) {
  if (countingDown) {
    return 'Not due yet — this was asked for a later time. The clock counts '
        'down to it and never turns red before then.';
  }
  final critical = veryUrgentMins + (veryUrgentMins - urgentMins);
  final state = minutes >= critical
      ? 'badly late'
      : minutes >= veryUrgentMins
          ? 'late'
          : minutes >= urgentMins
              ? 'getting on'
              : 'on time';
  return 'Waiting $minutes min — $state. '
      'Amber at $urgentMins, red at $veryUrgentMins, deep red at $critical.';
}

/// What the flag on a ticket means, and what tapping it does next.
///
/// The flag was an unlabelled icon that silently cycled three states: a cook
/// could not tell what the colour meant, nor what one more tap would do.
String priorityMeaning(KitchenOrderPriority priority) => switch (priority) {
      KitchenOrderPriority.normal =>
        'Normal priority. Tap to flag it as high.',
      KitchenOrderPriority.high =>
        'Flagged HIGH — push it up the order. Tap to make it urgent.',
      KitchenOrderPriority.urgent =>
        'Flagged URGENT — do this one next. Tap to clear the flag.',
    };
