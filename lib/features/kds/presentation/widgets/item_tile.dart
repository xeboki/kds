import 'package:flutter/material.dart';
import '../../../../core/theme/kds_theme.dart';
import '../../domain/line_meanings.dart';
import '../../domain/models/kitchen_order.dart';

/// Single order-item row inside an order card.
class ItemTile extends StatelessWidget {
  const ItemTile({
    this.lineHeight = 42,
    super.key,
    required this.item,
    this.onMarkStarted,
    this.onMarkCompleted,
    this.onToggle86,
    this.show86Button = false,
  });

  final KitchenOrderItem item;
  final VoidCallback? onMarkStarted;
  final VoidCallback? onMarkCompleted;

  /// Mark the item off, or back on.
  ///
  /// SPEC-097 097-A. This tile has always *rendered* an 86'd line — red,
  /// struck through, badged — and there was no way to set it: `set86Item` sat
  /// on the repository with no caller. A long press, as on the till, because
  /// it is destructive enough that a brush of a sleeve should not do it.
  final VoidCallback? onToggle86;

  /// Draw a labelled 86 control rather than relying on the long press.
  ///
  /// On for the ticket sheet, which has the room for it, and off on a board
  /// card, whose rows are exactly one line tall. Without it 86 was reachable
  /// only by a long press with no affordance anywhere on the screen — and a
  /// mouse cannot perform that gesture at all, so on a mouse-driven till
  /// there was no way to mark a dish off.
  final bool show86Button;

  /// Exactly how tall this line is.
  ///
  /// Given, not arrived at. The board budgets a ticket in line-heights and
  /// then draws it; while the tile's height was whatever padding and text
  /// happened to add up to, the two disagreed and the card cropped a line
  /// with no count to say it had. A line is now the height the board paid
  /// for, and the type scales with it.
  final double lineHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final kitchen = context.kitchen;
    // `isVoided`, not the status alone: a line the till voided carries
    // `isCancelled` and an untouched status, and this read the status — so a
    // voided dish was drawn as ordinary work with a play button on it.
    final isVoided = item.isVoided;
    final isDone =
        item.status == KitchenItemStatus.completed || isVoided;
    final isHeld = item.status == KitchenItemStatus.held;
    final is86d = item.is86d;

    Color statusColor;
    switch (item.status) {
      case KitchenItemStatus.pending:
        statusColor = kitchen.statusPending;
      case KitchenItemStatus.preparing:
        statusColor = kitchen.statusPreparing;
      case KitchenItemStatus.completed:
        statusColor = kitchen.statusReady;
      case KitchenItemStatus.held:
        statusColor = kitchen.ageAmber;
      case KitchenItemStatus.cancelled:
        statusColor = kitchen.statusBumped;
    }
    if (isVoided) statusColor = kitchen.ageRed;

    // Type scales with the row, so "Small" is smaller writing rather than the
    // same writing in a shorter box.
    final scale = lineHeight / 42.0;
    return Tooltip(
      // The whole line, not the 8-pixel dot it used to wrap. A cook cannot
      // hover a dot that size, and a hover test proved the tooltip never
      // appeared — it was attached to a target nobody could reach.
      message: isVoided
          ? voidMeaning
          : is86d
              ? eightySixMeaning
              : statusMeaning(item.status),
      child: GestureDetector(
      onLongPress: onToggle86,
      child: Opacity(
      // A void stays legible. It is struck through and badged, not faded to
      // the point a cook glances past a dish they have already started.
      opacity: is86d ? 0.5 : (isVoided ? 0.75 : (isDone ? 0.45 : 1.0)),
      child: Container(
        // The gap between rows comes out of the line, not on top of it, so a
        // row's footprint is exactly the height the board budgeted. Added on
        // top it was four pixels a line — invisible on one, a cropped line by
        // the sixth.
        height: lineHeight - 4,
        margin: const EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7 * scale),
        decoration: BoxDecoration(
          color: item.isNewlyAdded
              ? kitchen.statusReady.withValues(alpha: 0.08)
              : item.isModified
                  ? kitchen.ageAmber.withValues(alpha: 0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: item.isNewlyAdded
              ? Border.all(color: kitchen.statusReady.withValues(alpha: 0.3))
              : item.isModified
                  ? Border.all(color: kitchen.ageAmber.withValues(alpha: 0.3))
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status dot
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8, top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),

                // Qty + name
                Expanded(
                  child: Text(
                    // Seat first, because a coursed table is plated by seat
                    // and the number is the only thing that says where the
                    // dish goes. Square has no seat numbers at all; the field
                    // was on our model and drawn nowhere.
                    item.seatNumber != null
                        ? 'S${item.seatNumber}  ${item.quantity}× ${item.productName}'
                        : '${item.quantity}× ${item.productName}',
                    // One line. The row is exactly the height the board
                    // budgeted for it, so a name that wrapped was simply cut
                    // in half by the bump button — worse than an ellipsis,
                    // because nothing said it had been cut.
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: is86d || isVoided
                          ? kitchen.ageRed
                          : colors.textPrimary,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      decoration: is86d || isDone || isVoided
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),

                // Void badge, before the others: it overrides them all. A
                // voided line is not held, not new and not work.
                if (isVoided)
                  _badge('VOID', kitchen.ageRed, why: voidMeaning),

                // Held badge
                if (isHeld && !isVoided)
                  _badge('HELD', kitchen.ageAmber,
                      why: statusMeaning(KitchenItemStatus.held)),

                // 86'd badge
                if (is86d && !isVoided)
                  _badge('86\'d', kitchen.ageRed, why: eightySixMeaning),

                // New / Modified badges
                if (item.isNewlyAdded && !isVoided)
                  _badge('NEW', kitchen.statusReady, why: newlyAddedMeaning),
                if (item.isModified && !item.isNewlyAdded && !isVoided)
                  _badge('MOD', kitchen.ageAmber, why: modifiedMeaning),

                // Putting a line back on is as necessary as taking it off,
                // and the block above is hidden once it is 86'd.
                if (show86Button && is86d && !isVoided && onToggle86 != null)
                  _iconBtn(Icons.restart_alt, kitchen.statusReady,
                      onToggle86!, tooltip: 'Put back on'),

                // Action buttons
                if (!isDone && !isHeld && !is86d && !isVoided) ...[
                  const SizedBox(width: 6),
                  if (item.status == KitchenItemStatus.pending &&
                      onMarkStarted != null)
                    _iconBtn(Icons.play_arrow_rounded, kitchen.statusPreparing,
                        onMarkStarted!),
                  if (item.status == KitchenItemStatus.preparing &&
                      onMarkCompleted != null)
                    _iconBtn(Icons.check_circle_outline, kitchen.statusReady,
                        onMarkCompleted!),
                  if (show86Button && onToggle86 != null)
                    _iconBtn(Icons.block, kitchen.ageRed, onToggle86!,
                        tooltip: "86 this line"),
                ],
              ],
            ),

            // Modifiers
            if (item.modifiers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.modifiers
                      .map((m) => Text(
                            '${m.action.label} ${m.name}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12 * scale,
                            ),
                          ))
                      .toList(),
                ),
              ),

            // Special instructions
            if (item.hasSpecialInstructions)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Text(
                  item.specialInstructions!,
                  style: TextStyle(
                    color: kitchen.ageAmber,
                    fontSize: 12 * scale,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Cooking preference
            if (item.hasCookingPreference)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Text(
                  item.cookingPreference!,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12 * scale,
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
      ),
    );
  }

  /// [why] is shown on hover, for a cook driving the screen with a mouse who
  /// cannot know what a three-letter badge means.
  Widget _badge(String label, Color color, {String? why}) => Tooltip(
        message: why ?? '',
        child: Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap,
          {String? tooltip}) =>
      Tooltip(
        message: tooltip ?? '',
        // An empty message draws no tooltip, so the unlabelled buttons are
        // unchanged.
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      );
}
