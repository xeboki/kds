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
import 'ticket_sheet.dart';
import 'timer_badge.dart';

/// Main KDS order card. Shows order header, items, and bump controls.
class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    this.maxLines,
    this.lineHeight = 42,
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

  /// How many lines this card has room for, or null for all of them.
  ///
  /// The board gives a ticket as many vertical slots as its lines need, so
  /// this only bites on an order longer than a whole column. Showing a subset
  /// and saying so beats the two things it replaces: an inner scroll on a
  /// screen read from two metres away, and a second page that — in Square's
  /// case, per their own forums — users report being unable to reach.
  final int? maxLines;

  /// How tall one line is, so the card draws what the board budgeted.
  final double lineHeight;

  int get _totalLines =>
      order.linesFor(routingCategoryIds, isExpo: isExpo).length;

  /// Lines this card will actually draw.
  ///
  /// One short of the budget when anything is hidden, because the "+N more"
  /// notice occupies a row of its own in the footer. Without that the notice
  /// pushes the last line out of a clipped box and the count it quotes is
  /// one too few — a number that is wrong only when it matters.
  int? get _shownLines {
    final budget = maxLines;
    if (budget == null) return null;
    return _totalLines > budget ? budget - 1 : budget;
  }

  /// Lines this card has no room for.
  ///
  /// Only ever non-zero for an order longer than a whole column, which the
  /// board caps rather than letting it scroll or spill onto a page that — in
  /// Square's case, per their own forums — users report being unable to reach.
  int get _hiddenLines {
    final shown = _shownLines;
    if (shown == null) return 0;
    final hidden = _totalLines - shown;
    return hidden > 0 ? hidden : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    final repo = ref.read(kitchenRepositoryProvider);
    final session = ref.watch(sessionProvider);

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
        // Sized to its content, capped by the board. `Expanded` below would
        // demand a bounded height and throw in a column that has none.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _CardHeader(
            order: order,
            repo: repo,
            routingCategoryIds: routingCategoryIds,
            isExpo: isExpo,
            urgentMins: session?.urgentThresholdMins ?? 8,
            veryUrgentMins: session?.veryUrgentThresholdMins ?? 15,
          ),

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
          //
          // No scroll view. The board sizes the slot to the lines, and the
          // one case that does not fit — an order longer than a whole column —
          // is truncated with a count rather than hidden behind a gesture.
          Flexible(
            fit: FlexFit.loose,
            // Clipped. The slot is sized from a line count, and a line that
            // turns out a few pixels taller than the estimate must crop
            // rather than paint across the bump button — which is what
            // "+3 more" did, landing outside the card entirely.
            child: ClipRect(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: _ItemsBody(
                  order: order,
                  repo: repo,
                  maxLines: _shownLines,
                  lineHeight: lineHeight,
                  routingCategoryIds: routingCategoryIds,
                  isExpo: isExpo),
              ),
            ),
          ),

          // ── Footer: special instructions + bump ──────────────────────────────
          // The hidden-line count lives in the footer, which has a fixed
          // height, so it is always on the card however the lines above it
          // measure out.
          _CardFooter(
            order: order,
            repo: repo,
            hiddenLines: _hiddenLines,
            onOpen: () => showTicketSheet(
              context,
              order: order,
              routingCategoryIds: routingCategoryIds,
              isExpo: isExpo,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.order,
    required this.repo,
    required this.routingCategoryIds,
    required this.isExpo,
    required this.urgentMins,
    required this.veryUrgentMins,
  });

  /// When this screen's tickets turn amber and red, from its own back-office
  /// configuration. Passed down rather than read here, the way `repo` is.
  final int urgentMins;
  final int veryUrgentMins;

  /// The screen's own switches, so the count reports the lines this screen is
  /// responsible for rather than the whole order.
  final List<String> routingCategoryIds;
  final bool isExpo;

  final KitchenOrder order;
  // Typed, not `dynamic`: the analyzer cannot see a missing member on a
  // dynamic receiver, which is how a removed field became a runtime
  // NoSuchMethodError and a blank board (SPEC-097).
  final KitchenRepository repo;

  /// Counted the same way the body renders them — through `linesFor` — so the
  /// header cannot claim forty on a grill screen that is showing six.
  int get _lineCount =>
      order.linesFor(routingCategoryIds, isExpo: isExpo).length;

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
                InkWell(
                  // Opens the whole ticket. On a truncated one the "+N more"
                  // line is the obvious way in; this is the way in for every
                  // other ticket, and for anyone who reaches for the number.
                  onTap: () => showTicketSheet(
                    context,
                    order: order,
                    routingCategoryIds: routingCategoryIds,
                    isExpo: isExpo,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    '#${order.orderNumber}',
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _TypeChip(order.orderType),
                    if (order.tableNumber != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        tableLabel(order.tableNumber!),
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
                    // How big this ticket is, said on the ticket.
                    //
                    // The lines scroll inside the card, and nothing announced
                    // that there were more below the fold. On a forty-line
                    // order a cook reads eight and bumps — the card looks
                    // complete, because a card with eight lines looks exactly
                    // like a card with eight lines.
                    if (_lineCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '·  ${itemCount(_lineCount)}',
                        style: TextStyle(
                            color: colors.textSecondary, fontSize: 12),
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
          // The thresholds this screen was configured with, not the widget's
          // defaults. Until these were settings, every kitchen in the product
          // turned amber at 8 minutes and red at 15.
          //
          // The deep-red tier is derived — the same step again past red —
          // rather than being a third unconfigurable constant sitting behind
          // two settings.
          TimerBadge(
            orderTime: order.orderTime,
            urgentMins: urgentMins,
            veryUrgentMins: veryUrgentMins,
            criticalMins: veryUrgentMins + (veryUrgentMins - urgentMins),
          ),
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
    this.maxLines,
    this.lineHeight = 42,
    this.routingCategoryIds = const [],
    this.isExpo = false,
  });

  final int? maxLines;
  final double lineHeight;
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
      final all = order.linesFor(routingCategoryIds, isExpo: isExpo);
      final budget = maxLines;
      // One line of the budget is spent on the "+N more" row itself, or it
      // would push the card past the slot it was given.
      final shown = budget != null && all.length > budget
          ? all.take(budget).toList()
          : all;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...shown.map((item) => ItemTile(
                item: item,
                lineHeight: lineHeight,
                onMarkStarted: () =>
                    repo.markItemStarted(order.id, item.id),
                onMarkCompleted: () =>
                    repo.markItemCompleted(order.id, item.id),
                onToggle86: () => repo.set86Item(order.id, item.id,
                    is86d: !item.is86d),
              )),
        ],
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
  const _CardFooter({
    required this.order,
    required this.repo,
    this.hiddenLines = 0,
    this.onOpen,
  });

  /// Opens the whole ticket. The "+N more" line is useless without it — it
  /// named five lines a cook had no way to read, and told them to walk to
  /// another screen to do it.
  final VoidCallback? onOpen;

  /// Lines the card had no room for, said above the bump button so nobody
  /// clears a ticket they have only half read.
  final int hiddenLines;

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

          // Said right above the bump button, because that is the button
          // somebody is about to press on a ticket they have only half read.
          if (hiddenLines > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+$hiddenLines more',
                        style: TextStyle(
                            color: kitchen.ageAmber,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '— tap to open',
                        style: TextStyle(
                            color: kitchen.ageAmber,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.open_in_full,
                          size: 12, color: kitchen.ageAmber),
                    ],
                  ),
                ),
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

/// How a table reads on a ticket.
///
/// The bare `T` prefix assumes every table is a number. On a floor whose
/// tables are called "B10", "Walk 1" or "Terrace 4" it produced **TB10**,
/// **TWalk 1** and **TTerrace 4** — which is what a 25-ticket service looked
/// like the first time one was rung. Prefixed only when the name is numeric,
/// which is the case the prefix was written for.
String tableLabel(String tableNumber) {
  // Trim once and use that, rather than trimming for the test and printing
  // the original — " 7 " came out as "T 7 ".
  final name = tableNumber.trim();
  return RegExp(r'^\d+$').hasMatch(name) ? 'T$name' : name;
}

/// "1 item", "2 items". A ticket that says "1 items" is a ticket somebody
/// wrote and nobody read.
String itemCount(int n) => n == 1 ? '1 item' : '$n items';
