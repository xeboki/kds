import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/kitchen_order.dart';

/// Single order-item row inside an order card.
class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    this.onMarkStarted,
    this.onMarkCompleted,
  });

  final KitchenOrderItem item;
  final VoidCallback? onMarkStarted;
  final VoidCallback? onMarkCompleted;

  @override
  Widget build(BuildContext context) {
    final isDone = item.status == KitchenItemStatus.completed ||
        item.status == KitchenItemStatus.cancelled;
    final isHeld = item.status == KitchenItemStatus.held;
    final is86d = item.is86d;

    Color statusColor;
    switch (item.status) {
      case KitchenItemStatus.pending:
        statusColor = KdsTheme.statusPending;
      case KitchenItemStatus.preparing:
        statusColor = KdsTheme.statusPreparing;
      case KitchenItemStatus.completed:
        statusColor = KdsTheme.statusReady;
      case KitchenItemStatus.held:
        statusColor = KdsTheme.ageAmber;
      case KitchenItemStatus.cancelled:
        statusColor = KdsTheme.statusBumped;
    }

    return Opacity(
      opacity: isDone ? 0.45 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: item.isNewlyAdded
              ? KdsTheme.statusReady.withValues(alpha: 0.08)
              : item.isModified
                  ? KdsTheme.ageAmber.withValues(alpha: 0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: item.isNewlyAdded
              ? Border.all(color: KdsTheme.statusReady.withValues(alpha: 0.3))
              : item.isModified
                  ? Border.all(color: KdsTheme.ageAmber.withValues(alpha: 0.3))
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
                    style: TextStyle(
                      color: is86d ? KdsTheme.ageRed : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: is86d || isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),

                // Held badge
                if (isHeld)
                  _badge('HELD', KdsTheme.ageAmber),

                // 86'd badge
                if (is86d)
                  _badge('86\'d', KdsTheme.ageRed),

                // New / Modified badges
                if (item.isNewlyAdded)
                  _badge('NEW', KdsTheme.statusReady),
                if (item.isModified && !item.isNewlyAdded)
                  _badge('MOD', KdsTheme.ageAmber),

                // Action buttons
                if (!isDone && !isHeld && !is86d) ...[
                  const SizedBox(width: 6),
                  if (item.status == KitchenItemStatus.pending &&
                      onMarkStarted != null)
                    _iconBtn(Icons.play_arrow_rounded, KdsTheme.statusPreparing,
                        onMarkStarted!),
                  if (item.status == KitchenItemStatus.preparing &&
                      onMarkCompleted != null)
                    _iconBtn(Icons.check_circle_outline, KdsTheme.statusReady,
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
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
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
                  style: const TextStyle(
                    color: KdsTheme.ageAmber,
                    fontSize: 12,
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
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
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
