import 'package:flutter/material.dart';
import '../../../../core/theme/kds_theme.dart';
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
    final isDone = item.status == KitchenItemStatus.completed ||
        item.status == KitchenItemStatus.cancelled;
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

    // Type scales with the row, so "Small" is smaller writing rather than the
    // same writing in a shorter box.
    final scale = lineHeight / 42.0;
    return GestureDetector(
      onLongPress: onToggle86,
      child: Opacity(
      opacity: is86d ? 0.5 : (isDone ? 0.45 : 1.0),
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
                    '${item.quantity}× ${item.productName}',
                    // One line. The row is exactly the height the board
                    // budgeted for it, so a name that wrapped was simply cut
                    // in half by the bump button — worse than an ellipsis,
                    // because nothing said it had been cut.
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: is86d ? kitchen.ageRed : colors.textPrimary,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      decoration: is86d || isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),

                // Held badge
                if (isHeld)
                  _badge('HELD', kitchen.ageAmber),

                // 86'd badge
                if (is86d)
                  _badge('86\'d', kitchen.ageRed),

                // New / Modified badges
                if (item.isNewlyAdded)
                  _badge('NEW', kitchen.statusReady),
                if (item.isModified && !item.isNewlyAdded)
                  _badge('MOD', kitchen.ageAmber),

                // Action buttons
                if (!isDone && !isHeld && !is86d) ...[
                  const SizedBox(width: 6),
                  if (item.status == KitchenItemStatus.pending &&
                      onMarkStarted != null)
                    _iconBtn(Icons.play_arrow_rounded, kitchen.statusPreparing,
                        onMarkStarted!),
                  if (item.status == KitchenItemStatus.preparing &&
                      onMarkCompleted != null)
                    _iconBtn(Icons.check_circle_outline, kitchen.statusReady,
                        onMarkCompleted!),
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
    );
  }

  Widget _badge(String label, Color color) => Container(
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
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(icon, size: 18, color: color),
        ),
      );
}
