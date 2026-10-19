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
import 'order_card.dart' show courseName, itemCount, tableLabel;

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
    // Grouped the same way the card groups it. The card drew
    // "COURSE 1 — APPETISER" and the sheet behind it drew one flat list, so
    // opening a coursed ticket to read the lines the card could not fit lost
    // the course structure — on the surface with the most room for it.
    final byCourse = order.coursesFor(routingCategoryIds, isExpo: isExpo);
    final courses = byCourse.keys.toList()..sort();
    final coursed = courses.length > 1;

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
                            if (order.guestCount != null &&
                                order.guestCount! > 0)
                              '${order.guestCount} '
                                  '${order.guestCount == 1 ? 'cover' : 'covers'}',
                            if (order.serverName != null &&
                                order.serverName!.trim().isNotEmpty)
                              order.serverName!.trim(),
                            itemCount(lines.length),
                          ].join('  ·  '),
                          style: TextStyle(
                              fontSize: 13, color: colors.textSecondary),
                        ),
                        // The time it is wanted for, spelled out in full on
                        // the one surface with room for it.
                        if (order.scheduledFor != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Due ${_dueLabel(order.scheduledFor!.toLocal())}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.info),
                            ),
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
                  for (final course in courses) ...[
                    if (coursed)
                      Padding(
                        padding: EdgeInsets.only(
                            top: course == courses.first ? 0 : 14, bottom: 6),
                        child: Row(
                          children: [
                            Text(
                              courseName(course),
                              style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1),
                            ),
                            const Spacer(),
                            if (byCourse[course]!
                                .every((i) => i.status == KitchenItemStatus.held))
                              TextButton(
                                onPressed: () =>
                                    repo.fireCourse(order.id, course),
                                child: Text('FIRE',
                                    style: TextStyle(
                                        color: kitchen.statusPreparing,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ),
                          ],
                        ),
                      ),
                  for (final item in byCourse[course]!) ...[
                    ItemTile(
                      item: item,
                      // The surface with room for a labelled control. On the
                      // board a line is one row tall and 86 stays a long
                      // press; here it is a button a cook can see.
                      show86Button: true,
                      onMarkStarted: () =>
                          repo.markItemStarted(order.id, item.id),
                      onMarkCompleted: () =>
                          repo.markItemCompleted(order.id, item.id),
                      onToggle86: () => repo.set86Item(order.id, item.id,
                          is86d: !item.is86d),
                    ),
                    // Why it was voided. The card has one fixed-height row
                    // per line and can only badge the void; this is the
                    // surface with room to say what a server actually did.
                    if (item.isVoided &&
                        item.cancelReason != null &&
                        item.cancelReason!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 6),
                        child: Text(
                          'Voided — ${item.cancelReason!.trim()}',
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: kitchen.ageRed),
                        ),
                      ),
                  ],
                  ],
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
                    repo.bumpForScreen(
                      order.id,
                      routingCategoryIds: routingCategoryIds,
                      isExpo: isExpo,
                    );
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

/// A due time a cook can read at a glance: the clock alone when it is today,
/// the date too when it is not.
String _dueLabel(DateTime at) {
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  final now = DateTime.now();
  final sameDay =
      at.year == now.year && at.month == now.month && at.day == now.day;
  return sameDay ? 'today $hh:$mm' : '${at.day}/${at.month} at $hh:$mm';
}
