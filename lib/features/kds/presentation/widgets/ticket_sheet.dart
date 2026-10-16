/// The whole ticket, when the card could not hold it.
///
/// The board truncates an order longer than a column and says "+5 more" — and
/// for one build that was the end of the sentence. It told a cook that five
/// lines existed and gave them no way to read them; "open on the pass" is an
/// instruction to walk to another screen mid-service, which is not a thing
/// anyone does holding a pan, and assumes an expo screen that a kitchen may
/// not have set up at all.
///
/// So the ticket opens where it is, on one tap. Everything a line can do on
/// the board it can do here — start, complete, 86 — and the bump is the same
/// bump, so a cook who opens a ticket to read the end of it can clear it from
/// the same place rather than closing and hunting for the card again.
///
/// This is the one surface in the app allowed to scroll. It is a thing you
/// opened on purpose, one list deep, rather than a board you were trying to
/// read at a glance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kds_theme.dart';
import '../../domain/models/kitchen_order.dart';
import '../providers/kitchen_providers.dart';
import 'item_tile.dart';
import 'order_card.dart' show itemCount, tableLabel;

Future<void> showTicketSheet(
  BuildContext context, {
  required KitchenOrder order,
  required List<String> routingCategoryIds,
  required bool isExpo,
}) =>
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _TicketSheet(
        order: order,
        routingCategoryIds: routingCategoryIds,
        isExpo: isExpo,
      ),
    );

class _TicketSheet extends ConsumerWidget {
  const _TicketSheet({
    required this.order,
    required this.routingCategoryIds,
    required this.isExpo,
  });

  final KitchenOrder order;
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final kitchen = context.kitchen;
    final repo = ref.read(kitchenRepositoryProvider);
    final lines = order.linesFor(routingCategoryIds, isExpo: isExpo);

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${order.orderNumber}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary)),
                        Text(
                          [
                            if (order.tableNumber != null)
                              tableLabel(order.tableNumber!),
                            itemCount(lines.length),
                          ].join('  ·  '),
                          style: TextStyle(
                              fontSize: 13, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            if (order.allergyInfo != null && order.allergyInfo!.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: kitchen.ageRed.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: kitchen.ageRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(order.allergyInfo!,
                          style: TextStyle(
                              color: kitchen.ageRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                children: [
                  for (final item in lines)
                    ItemTile(
                      item: item,
                      onMarkStarted: () =>
                          repo.markItemStarted(order.id, item.id),
                      onMarkCompleted: () =>
                          repo.markItemCompleted(order.id, item.id),
                      onToggle86: () => repo.set86Item(order.id, item.id,
                          is86d: !item.is86d),
                    ),
                ],
              ),
            ),
            if (order.specialInstructions != null &&
                order.specialInstructions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(order.specialInstructions!,
                    style: TextStyle(
                        color: kitchen.ageAmber,
                        fontSize: 13,
                        fontStyle: FontStyle.italic)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton.icon(
                  // The same bump as the card's. A cook who opened the ticket
                  // to read the end of it should not have to close this and
                  // find the card again to clear it.
                  onPressed: () {
                    repo.bumpOrder(order.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('BUMP',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kitchen.statusPreparing,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
