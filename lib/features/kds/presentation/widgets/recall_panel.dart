/// Bringing a bumped ticket back.
///
/// SPEC-097 097-A, ported from the till's own Kitchen Display. The repository
/// has had `getBumpedOrders` and `recallOrder` since this app was written and
/// **nothing called them**: once a ticket was bumped it was gone, from a board
/// whose bump button is a single tap with no confirmation.
///
/// That is the one irreversible action on the screen, and a kitchen needs it
/// reversible: a cook bumps the wrong card, a table sends a plate back, a
/// ticket is bumped before the garnish goes on. Without recall the only
/// remedy is ringing the order again at the till.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kds_theme.dart';
import '../../domain/models/kitchen_order.dart';
import '../providers/kitchen_providers.dart';

Future<void> showRecallPanel(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RecallPanel(),
    );

class RecallPanel extends ConsumerWidget {
  const RecallPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final bumped = ref.watch(bumpedOrdersProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.history, color: colors.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Recall a bumped ticket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: bumped.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 48, color: colors.success),
                          const SizedBox(height: 12),
                          Text('Nothing has been bumped yet',
                              style: TextStyle(color: colors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) => _RecallTile(
                      order: orders[i],
                      onRecall: () async {
                        await ref
                            .read(kitchenRepositoryProvider)
                            .recallOrder(orders[i].id);
                        // The list is a one-shot read, so it has to be told.
                        ref.invalidate(bumpedOrdersProvider);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Could not load bumped tickets — $e',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.kitchen.ageRed)),
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

class _RecallTile extends StatelessWidget {
  const _RecallTile({required this.order, required this.onRecall});

  final KitchenOrder order;
  final VoidCallback onRecall;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bumpedAgo = order.bumpedAt != null
        ? DateTime.now().difference(order.bumpedAt!).inMinutes
        : order.waitTimeMinutes;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          order.orderNumber,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.success),
          textAlign: TextAlign.center,
        ),
      ),
      title: Text(
        order.tableNumber != null
            ? 'Table ${order.tableNumber}'
            : 'Order ${order.orderNumber}',
        style:
            TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
      ),
      subtitle: Text(
        '${order.items.length} item${order.items.length == 1 ? '' : 's'}'
        ' · bumped ${bumpedAgo}m ago',
        style: TextStyle(fontSize: 12, color: colors.textSecondary),
      ),
      trailing: OutlinedButton(
        onPressed: onRecall,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.warning,
          side: BorderSide(color: colors.warning),
        ),
        child: const Text('Recall'),
      ),
    );
  }
}
