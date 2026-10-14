import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/kds_theme.dart';
import '../../domain/models/kitchen_order.dart';
import '../../domain/repositories/kitchen_repository.dart';
import '../../domain/printing/kitchen_ticket_pdf.dart';
import '../providers/kitchen_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'item_tile.dart';
import 'timer_badge.dart';

/// Main KDS order card. Shows order header, items, and bump controls.
class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.routingCategoryIds = const [],
    this.isExpo = false,
  });

  final KitchenOrder order;

  /// SPEC-097, Square's model: the kitchen routing categories this screen is
  /// switched on for. Until this existed every screen showed every line.
  final List<String> routingCategoryIds;

  /// An expo screen assembles the whole order and shows every line.
  final bool isExpo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    final repo = ref.read(kitchenRepositoryProvider);

    Color borderColor;
    switch (order.status) {
      case KitchenOrderStatus.pending:
        borderColor = kitchen.statusPending;
      case KitchenOrderStatus.preparing:
        borderColor = kitchen.statusPreparing;
      case KitchenOrderStatus.ready:
        borderColor = kitchen.statusReady;
      case KitchenOrderStatus.recalled:
        borderColor = kitchen.ageRed;
      default:
        borderColor = Colors.transparent;
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _CardHeader(order: order, repo: repo),

          // ── Allergy alert ────────────────────────────────────────────────────
          if (order.allergyInfo != null && order.allergyInfo!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: kitchen.ageRed.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 14, color: kitchen.ageRed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.allergyInfo!,
                      style: TextStyle(
                          color: kitchen.ageRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // ── Items ────────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: _ItemsBody(
                  order: order,
                  repo: repo,
                  routingCategoryIds: routingCategoryIds,
                  isExpo: isExpo),
            ),
          ),

          // ── Footer: special instructions + bump ──────────────────────────────
          _CardFooter(order: order, repo: repo),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.order, required this.repo});

  final KitchenOrder order;
  // Typed, not `dynamic`: the analyzer cannot see a missing member on a
  // dynamic receiver, which is how a removed field became a runtime
  // NoSuchMethodError and a blank board (SPEC-097).
  final KitchenRepository repo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          // Order number + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.orderNumber}',
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _TypeChip(order.orderType),
                    if (order.tableNumber != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'T${order.tableNumber}',
                        style: TextStyle(
                            color: colors.textSecondary, fontSize: 12),
                      ),
                    ],
                    if (order.sourceLabel != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        order.sourceLabel!,
                        style: TextStyle(
                            color: colors.primary, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // SPEC-097 097-A. The first kitchen ticket in this product that can
          // actually print — see kitchen_ticket_pdf.dart for what the till's
          // button did instead.
          PrintTicketButton(order: order),

          // Priority flag
          _PriorityIcon(order: order, repo: repo),

          const SizedBox(width: 8),

          // Age timer
          TimerBadge(orderTime: order.orderTime),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip(this.type);
  final KitchenOrderType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.label,
        style: TextStyle(
            color: colors.primary, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PriorityIcon extends StatelessWidget {
  const _PriorityIcon({required this.order, required this.repo});
  final KitchenOrder order;
  // Typed, not `dynamic`: the analyzer cannot see a missing member on a
  // dynamic receiver, which is how a removed field became a runtime
  // NoSuchMethodError and a blank board (SPEC-097).
  final KitchenRepository repo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final kitchen = context.kitchen;
    Color color;
    switch (order.priority) {
      case KitchenOrderPriority.high:
        color = kitchen.priorityHigh;
      case KitchenOrderPriority.urgent:
        color = kitchen.priorityUrgent;
      default:
        color = colors.onDisabled;
    }
    return GestureDetector(
      onTap: () {
        final next = order.priority == KitchenOrderPriority.normal
            ? KitchenOrderPriority.high
            : order.priority == KitchenOrderPriority.high
                ? KitchenOrderPriority.urgent
                : KitchenOrderPriority.normal;
        repo.updatePriority(order.id, next);
      },
      child: Icon(Icons.flag_rounded, size: 20, color: color),
    );
  }
}

// ── Items body ─────────────────────────────────────────────────────────────────

class _ItemsBody extends StatelessWidget {
  const _ItemsBody({
    required this.order,
    required this.repo,
    this.routingCategoryIds = const [],
    this.isExpo = false,
  });
  final KitchenOrder order;
  // Typed, not `dynamic`: the analyzer cannot see a missing member on a
  // dynamic receiver, which is how a removed field became a runtime
  // NoSuchMethodError and a blank board (SPEC-097).
  final KitchenRepository repo;
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final kitchen = context.kitchen;
    final byCourse =
        order.coursesFor(routingCategoryIds, isExpo: isExpo);
    if (byCourse.length <= 1) {
      // No course grouping
      return Column(
        children: order
            .linesFor(routingCategoryIds, isExpo: isExpo)
            .map((item) => ItemTile(
                  item: item,
                  onMarkStarted: () =>
                      repo.markItemStarted(order.id, item.id),
                  onMarkCompleted: () =>
                      repo.markItemCompleted(order.id, item.id),
                  onToggle86: () => repo.set86Item(order.id, item.id,
                      is86d: !item.is86d),
                ))
            .toList(),
      );
    }

    // Multi-course
    final courses = byCourse.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: courses.map((course) {
        final items = byCourse[course]!;
        final allHeld =
            items.every((i) => i.status == KitchenItemStatus.held);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _courseName(course),
                  style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1),
                ),
                const Spacer(),
                if (allHeld)
                  GestureDetector(
                    onTap: () => repo.fireCourse(order.id, course),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kitchen.statusPreparing.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: kitchen.statusPreparing.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'FIRE',
                        style: TextStyle(
                            color: kitchen.statusPreparing,
                            fontSize: 11,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            ...items.map((item) => ItemTile(
                  item: item,
                  onMarkStarted: allHeld
                      ? null
                      : () => repo.markItemStarted(order.id, item.id),
                  onMarkCompleted: allHeld
                      ? null
                      : () => repo.markItemCompleted(order.id, item.id),
                  // Offered on a held course too: a kitchen learns it has run
                  // out before the course is fired, not after.
                  onToggle86: () =>
                      repo.set86Item(order.id, item.id, is86d: !item.is86d),
                )),
            Divider(color: colors.border, height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _courseName(int n) {
    switch (n) {
      case 1:
        return 'COURSE 1 — APPETISER';
      case 2:
        return 'COURSE 2 — MAIN';
      case 3:
        return 'COURSE 3 — DESSERT';
      default:
        return 'COURSE $n';
    }
  }
}

// ── Footer ─────────────────────────────────────────────────────────────────────

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.order, required this.repo});
  final KitchenOrder order;
  // Typed, not `dynamic`: the analyzer cannot see a missing member on a
  // dynamic receiver, which is how a removed field became a runtime
  // NoSuchMethodError and a blank board (SPEC-097).
  final KitchenRepository repo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final kitchen = context.kitchen;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (order.specialInstructions != null &&
              order.specialInstructions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                order.specialInstructions!,
                style: TextStyle(
                    color: kitchen.ageAmber,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ),

          // Bump button
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () => repo.bumpOrder(order.id),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('BUMP',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: order.status == KitchenOrderStatus.ready
                    ? kitchen.statusReady
                    : kitchen.statusPreparing,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The print button on a ticket.
///
/// SPEC-097 097-A. Separate from the card so the card does not have to know
/// about PDFs, and so the one place that decides *which lines print* is the
/// same rule the board filters by — a grill screen prints the grill's lines,
/// the pass prints the whole order.
class PrintTicketButton extends ConsumerStatefulWidget {
  const PrintTicketButton({super.key, required this.order});

  final KitchenOrder order;

  @override
  ConsumerState<PrintTicketButton> createState() => _PrintTicketButtonState();
}

class _PrintTicketButtonState extends ConsumerState<PrintTicketButton> {
  bool _busy = false;

  Future<void> _print() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _busy = true);
    try {
      final bytes = await buildKitchenTicketPdf(
        widget.order,
        screenRoutingCategoryIds: session.routingCategoryIds,
        isExpo: session.isExpo,
        locationName: session.locationName,
      );
      // Hands the document to the browser's own print dialog. The till's
      // socket-based route cannot work here — see kitchen_ticket_pdf.dart.
      await Printing.layoutPdf(
        onLayout: (_) async => Uint8List.fromList(bytes),
        name: 'Kitchen-${widget.order.orderNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not print this ticket — $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: _busy ? null : _print,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: _busy
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.textSecondary),
              )
            : Icon(Icons.print_outlined,
                size: 18, color: colors.textSecondary),
      ),
    );
  }
}
