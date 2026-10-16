import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kds_theme.dart';
import '../../domain/models/kitchen_order.dart';
import '../../../auth/domain/models/kds_session.dart';
import '../providers/kitchen_providers.dart';
import '../widgets/analytics_panel.dart';
import '../widgets/board_pagination.dart';
import '../widgets/order_card.dart';
import '../widgets/recall_panel.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class KitchenDisplayScreen extends ConsumerStatefulWidget {
  const KitchenDisplayScreen({super.key});

  @override
  ConsumerState<KitchenDisplayScreen> createState() =>
      _KitchenDisplayScreenState();
}

class _KitchenDisplayScreenState
    extends ConsumerState<KitchenDisplayScreen>
    with SingleTickerProviderStateMixin {
  // New-order alert animation
  late AnimationController _alertCtrl;
  late Animation<double> _alertFade;
  Timer? _alertTimer;

  @override
  void initState() {
    super.initState();
    _alertCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _alertFade = CurvedAnimation(parent: _alertCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _alertCtrl.dispose();
    _alertTimer?.cancel();
    super.dispose();
  }

  void _triggerAlert() {
    _alertCtrl.forward(from: 0);
    _alertTimer?.cancel();
    _alertTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _alertCtrl.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    final session = ref.watch(sessionProvider);
    final ordersAsync = ref.watch(kitchenOrdersProvider);
    final colCount = ref.watch(columnCountProvider);
    final ticketSize = ref.watch(ticketSizeProvider);
    final viewMode = ref.watch(viewModeProvider);

    // Detect new orders and trigger alert
    ref.listen<AsyncValue<List<KitchenOrder>>>(kitchenOrdersProvider,
        (prev, next) {
      next.whenData((orders) {
        final ids = orders.map((o) => o.id).toSet();
        final known = ref.read(knownOrderIdsProvider);
        if (known == null) {
          ref.read(knownOrderIdsProvider.notifier).state = ids;
          return;
        }
        final newIds = ids.difference(known);
        if (newIds.isNotEmpty) {
          ref.read(knownOrderIdsProvider.notifier).state = ids;
          _triggerAlert();
        }
      });
    });

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, session, viewMode, colCount, ticketSize),
      body: Stack(
        children: [
          ordersAsync.when(
            loading: () => Center(
                child: CircularProgressIndicator(color: colors.primary)),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style: TextStyle(color: kitchen.ageRed)),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return const _EmptyBoard();
              }
              switch (viewMode) {
                case KdsViewMode.grid:
                  return _GridView(
                      orders: orders,
                      colCount: colCount,
                      ticketSize: ticketSize,
                      routingCategoryIds:
                          session?.routingCategoryIds ?? const [],
                      isExpo: session?.isExpo ?? false);
                case KdsViewMode.tableView:
                  return _TableConsolidatedView(
                      orders: orders,
                      colCount: colCount,
                      ticketSize: ticketSize,
                      routingCategoryIds:
                          session?.routingCategoryIds ?? const [],
                      isExpo: session?.isExpo ?? false);
                case KdsViewMode.expoView:
                  // No station: the expediter assembles the whole order and
                  // has to see every line, whichever station is making it.
                  return _ExpoView(orders: orders);
              }
            },
          ),

          // New-order alert banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _alertFade,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: Colors.deepOrange.withValues(alpha: 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_active,
                        color: colors.textPrimary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'NEW ORDER',
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    // Typed, not `dynamic`. SPEC-097: this took `dynamic session` and read
    // `session.stationId` after that field was removed. The analyzer cannot
    // see a missing member on `dynamic`, so `flutter analyze` stayed clean,
    // every test passed, and the board threw NoSuchMethodError on build and
    // rendered a blank grey screen.
    KdsSession? session,
    KdsViewMode viewMode,
    int colCount,
    int ticketSize,
  ) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kitchen Display',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (session != null)
            Text(
              '${session.locationName} · '
              '${session.isExpo ? 'Expo station' : 'Prep station'}',
              style:
                  TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
        ],
      ),
      actions: [
        // SPEC-097 097-A. Bump is one tap with no confirmation, and until this
        // existed it was the only irreversible thing on the board — a ticket
        // bumped by mistake could only be recovered by ringing the order
        // again at the till. The repository has had `recallOrder` all along.
        IconButton(
          tooltip: 'Recall a bumped ticket',
          icon: Icon(Icons.history, color: colors.textSecondary),
          onPressed: () => showRecallPanel(context),
        ),

        // SPEC-097 097-A. The board shows the tickets that are open and
        // nothing else, so the shape of a service — the backlog, the oldest
        // wait, what went out in the last hour — could only be counted by eye.
        IconButton(
          tooltip: 'Kitchen analytics',
          icon: Icon(Icons.bar_chart, color: colors.textSecondary),
          onPressed: () => showAnalyticsPanel(context),
        ),

        // View mode toggle
        IconButton(
          tooltip: 'Toggle view',
          icon: Icon(
            viewMode == KdsViewMode.grid
                ? Icons.grid_view_rounded
                : viewMode == KdsViewMode.tableView
                    ? Icons.table_restaurant
                    : Icons.list_alt_rounded,
            color: colors.textSecondary,
          ),
          onPressed: () =>
              ref.read(viewModeProvider.notifier).cycle(),
        ),

        // Column count picker
        IconButton(
          tooltip: 'Board layout',
          icon: Icon(Icons.settings, color: colors.textSecondary),
          onPressed: () =>
              _showLayoutPicker(context, colCount, ticketSize),
        ),

        // Logout
        IconButton(
          tooltip: 'Sign out',
          icon: Icon(Icons.logout, color: colors.onDisabled),
          onPressed: () async {
            await ref.read(sessionProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
        ),
      ],
    );
  }

  /// Columns and rows — the page size of the board.
  ///
  /// Both, because together they decide how much of a service fits before the
  /// board starts a second page, and a kitchen with a tall screen and one with
  /// a wide one want different answers. Toast exposes the same pair.
  void _showLayoutPicker(BuildContext context, int cols, int size) {
    final colors = context.appColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Board layout',
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Bigger writing fits fewer tickets before the board pages',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),
            _LayoutRow(
              label: 'Columns',
              values: const [2, 3, 4, 5, 6],
              current: cols,
              onPick: (n) => ref.read(columnCountProvider.notifier).set(n),
            ),
            const SizedBox(height: 16),
            _SizeRow(
              current: size,
              onPick: (n) => ref.read(ticketSizeProvider.notifier).set(n),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Grid view ──────────────────────────────────────────────────────────────────

class _GridView extends ConsumerStatefulWidget {
  const _GridView({
    required this.orders,
    required this.colCount,
    required this.ticketSize,
    this.routingCategoryIds = const [],
    this.isExpo = false,
  });
  final List<KitchenOrder> orders;
  final int colCount;
  final int ticketSize;

  /// Passed down so a card shows only the lines this screen is responsible
  /// for. SPEC-097, Square's model.
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  ConsumerState<_GridView> createState() => _GridViewState();
}

/// The board, as pages of a fixed grid — never a scroll.
///
/// It used to scroll twice: the page scrolled, and every ticket had its own
/// inner scroll. Reaching the fourth line of the eleventh order meant two
/// gestures in two nested surfaces, on a screen read from two metres away by
/// someone holding a pan.
///
/// Nobody good does that. Toast's KDS shows a fixed maximum of tickets per
/// screen and paginates, with page indicators, and lets a long ticket span
/// several grid slots. Square's rail and tile layouts page too — and their own
/// forums carry the cost of the alternative: a moderator recommending a layout
/// that "will require that you scroll longer tickets", and users who cannot
/// reach the second page of a long order at all.
class _GridViewState extends ConsumerState<_GridView> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    const gap = kCardGapPx;
    final lineHeight = kLinePx[widget.ticketSize]!;

    return LayoutBuilder(
      builder: (context, outer) {
        // The page bar only exists once there is more than one page, and
        // whether there is depends on the height left after it. Reserving the
        // space either way keeps the two from arguing: a board that gains a
        // page, shrinks, loses the page, grows, and gains it again.
        const barHeight = 52.0;
        final boardHeight = outer.maxHeight - barHeight - 24;
        final capacity = columnCapacity(boardHeight, widget.ticketSize);

        // Capacity is measured, not set: the board holds what the board holds.
        final pages = paginate(
          widget.orders,
          columns: widget.colCount,
          capacity: capacity,
          size: widget.ticketSize,
          screenRoutingCategoryIds: widget.routingCategoryIds,
          isExpo: widget.isExpo,
        );

        // A bump can shorten the board under you. Landing on a page that no
        // longer exists would show an empty screen in a busy kitchen.
        final page = _page.clamp(0, pages.length - 1);
        if (page != _page) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _page = page);
          });
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var c = 0; c < widget.colCount; c++) ...[
                      if (c > 0) const SizedBox(width: gap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final order in pages[page].columns[c])
                              _Slot(
                                order: order,
                                lineHeight: lineHeight,
                                gap: gap,
                                capacity: capacity,
                                size: widget.ticketSize,
                                routingCategoryIds: widget.routingCategoryIds,
                                isExpo: widget.isExpo,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(
              height: barHeight,
              child: pages.length > 1
                  ? _PageBar(
                      pages: pages.length,
                      current: page,
                      onChanged: (p) => setState(() => _page = p),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

/// One ticket, in the slots it was allotted.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.order,
    required this.lineHeight,
    required this.gap,
    required this.capacity,
    required this.size,
    required this.routingCategoryIds,
    required this.isExpo,
  });

  final KitchenOrder order;

  /// One line of a ticket, in logical pixels, at the chosen ticket size.
  final double lineHeight;
  final double gap;
  final int capacity;
  final int size;
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  Widget build(BuildContext context) {
    final cost = costOf(order,
        screenRoutingCategoryIds: routingCategoryIds,
        isExpo: isExpo,
        capacity: capacity,
        size: size);
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: SizedBox(
        // The gap is taken out of the card's own share, so a column of many
        // small tickets adds up to exactly the column rather than overflowing
        // it by one gap per ticket.
        height: (lineHeight * cost) - gap,
        child: OrderCard(
          order: order,
          lineHeight: lineHeight,
          // What fits in the share this ticket was given. Only an order
          // longer than a whole column is ever cut, and it says so.
          maxLines: cost - chromeInLines(size),
          routingCategoryIds: routingCategoryIds,
          isExpo: isExpo,
        ),
      ),
    );
  }
}

/// Which page of the board you are on, and how to move.
///
/// Tappable numbers, not just arrows: Toast's own guidance is that pagination
/// "can be tapped to move to a specific page quickly", and in a kitchen the
/// difference between one tap and four matters.
class _PageBar extends StatelessWidget {
  const _PageBar({
    required this.pages,
    required this.current,
    required this.onChanged,
  });

  final int pages;
  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Read here rather than passed in. It was a `dynamic` field, which is the
    // one thing the analyzer cannot check — and how a removed member became a
    // runtime NoSuchMethodError and a blank board once already.
    final colors = context.appColors;
    return Container(
      height: 52,
      color: colors.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.chevron_left),
            color: colors.textSecondary,
            onPressed: current > 0 ? () => onChanged(current - 1) : null,
          ),
          for (var p = 0; p < pages; p++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () => onChanged(p),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p == current ? colors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: p == current ? colors.primary : colors.border),
                  ),
                  child: Text(
                    '${p + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      // On the filled chip this must be on-primary; body text
                      // is near-black on this blue.
                      color:
                          p == current ? colors.onPrimary : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.chevron_right),
            color: colors.textSecondary,
            onPressed:
                current < pages - 1 ? () => onChanged(current + 1) : null,
          ),
        ],
      ),
    );
  }
}

// ── Table-consolidated view ────────────────────────────────────────────────────

/// The same service, grouped by table.
///
/// A table and its tickets travel together — that is the whole reason for this
/// view — so a table is the unit that gets packed, not a ticket. It pages on
/// the same packer the ticket board uses; two packers would drift, and the one
/// that drifted would be the one nobody was watching during a service.
///
/// It used to be a vertical list of full-width rows: one 360px card in a
/// 1600px row, twenty-five tables deep, scrolled. That is the fault this
/// screen spent the morning removing from the ticket board.
class _TableConsolidatedView extends ConsumerStatefulWidget {
  const _TableConsolidatedView({
    required this.orders,
    required this.colCount,
    required this.ticketSize,
    this.routingCategoryIds = const [],
    this.isExpo = false,
  });

  final List<KitchenOrder> orders;
  final int colCount;
  final int ticketSize;

  /// The table view is still this screen's board, grouped by table rather
  /// than by ticket.
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  ConsumerState<_TableConsolidatedView> createState() =>
      _TableConsolidatedViewState();
}

/// One table and everything on it.
class _TableGroup {
  const _TableGroup(this.table, this.orders);
  final String table;
  final List<KitchenOrder> orders;
}

class _TableConsolidatedViewState
    extends ConsumerState<_TableConsolidatedView> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    const gap = kCardGapPx;
    final lineHeight = kLinePx[widget.ticketSize]!;

    // Insertion order, which is the order the board already sorted into:
    // oldest first. Sorting by table number would put table 1 above a table 9
    // that has been waiting twice as long.
    final byTable = <String, List<KitchenOrder>>{};
    for (final o in widget.orders) {
      byTable.putIfAbsent(o.tableNumber ?? 'No Table', () => []).add(o);
    }
    final groups = byTable.entries
        .map((e) => _TableGroup(e.key, e.value))
        .toList();

    return LayoutBuilder(
      builder: (context, outer) {
        const barHeight = 52.0;
        final boardHeight = outer.maxHeight - barHeight - 24;
        final capacity = columnCapacity(boardHeight, widget.ticketSize);

        int costOfGroup(_TableGroup g) =>
            // One line for the table heading, then what its tickets cost.
            1 +
            g.orders.fold<int>(
                0,
                (sum, o) => sum +
                    costOf(o,
                        screenRoutingCategoryIds: widget.routingCategoryIds,
                        isExpo: widget.isExpo,
                        capacity: capacity,
                        size: widget.ticketSize));

        final pages = packColumns<_TableGroup>(
          groups,
          columns: widget.colCount,
          capacity: capacity,
          cost: costOfGroup,
        );

        final page = _page.clamp(0, pages.length - 1);
        if (page != _page) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _page = page);
          });
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var c = 0; c < widget.colCount; c++) ...[
                      if (c > 0) const SizedBox(width: gap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final group in pages[page][c])
                              _TableGroupBlock(
                                group: group,
                                lineHeight: lineHeight,
                                capacity: capacity,
                                size: widget.ticketSize,
                                routingCategoryIds: widget.routingCategoryIds,
                                isExpo: widget.isExpo,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(
              height: barHeight,
              child: pages.length > 1
                  ? _PageBar(
                      pages: pages.length,
                      current: page,
                      onChanged: (p) => setState(() => _page = p),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

/// A table heading and the tickets standing on it.
class _TableGroupBlock extends StatelessWidget {
  const _TableGroupBlock({
    required this.group,
    required this.lineHeight,
    required this.capacity,
    required this.size,
    required this.routingCategoryIds,
    required this.isExpo,
  });

  final _TableGroup group;
  final double lineHeight;
  final int capacity;
  final int size;
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: lineHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Table ${group.table}',
              style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1),
            ),
          ),
        ),
        for (final order in group.orders)
          _Slot(
            order: order,
            lineHeight: lineHeight,
            gap: kCardGapPx,
            capacity: capacity,
            size: size,
            routingCategoryIds: routingCategoryIds,
            isExpo: isExpo,
          ),
      ],
    );
  }
}


// ── Expo view ──────────────────────────────────────────────────────────────────

class _ExpoView extends StatelessWidget {
  const _ExpoView({required this.orders});
  final List<KitchenOrder> orders;

  @override
  Widget build(BuildContext context) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    final items = [
      for (final o in orders)
        for (final i in o.items)
          if (i.status != KitchenItemStatus.held &&
              i.status != KitchenItemStatus.cancelled)
            (order: o, item: i),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(color: colors.border, height: 1),
      itemBuilder: (_, idx) {
        final entry = items[idx];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Order tag
              Container(
                width: 80,
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${entry.order.orderNumber}',
                  style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              // Item name
              Expanded(
                child: Text(
                  '${entry.item.quantity}× ${entry.item.productName}',
                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                ),
              ),
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.item.status == KitchenItemStatus.completed
                      ? kitchen.statusReady
                      : entry.item.status == KitchenItemStatus.preparing
                          ? kitchen.statusPreparing
                          : kitchen.statusPending,
                ),
              ),
              const SizedBox(width: 8),
              // Table tag
              if (entry.order.tableNumber != null)
                Text(
                  tableLabel(entry.order.tableNumber!),
                  style: TextStyle(
                      color: colors.onDisabled, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, size: 64, color: colors.border),
          SizedBox(height: 16),
          Text(
            'No active orders',
            style: TextStyle(color: colors.onDisabled, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

/// One row of the board-layout picker.
class _LayoutRow extends StatelessWidget {
  const _LayoutRow({
    required this.label,
    required this.values,
    required this.current,
    required this.onPick,
  });

  final String label;
  final List<int> values;
  final int current;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: values.map((n) {
            final selected = n == current;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                // The sheet stays open: columns and rows are usually set
                // together, and closing after each one means opening it twice.
                onTap: () => onPick(n),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 54,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: selected ? colors.primary : colors.border),
                  ),
                  child: Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? colors.onPrimary : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// How big the writing on a ticket is.
///
/// Toast's own control, in the same three steps. It is the setting a kitchen
/// actually has an opinion about — a board read from across a pass wants
/// bigger type than one at arm's length — and it decides how much fits, which
/// is why there is no separate "rows" number to contradict it.
class _SizeRow extends StatelessWidget {
  const _SizeRow({required this.current, required this.onPick});

  final int current;
  final ValueChanged<int> onPick;

  static const _labels = ['Small', 'Medium', 'Large'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ticket size',
            style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_labels.length, (i) {
            final selected = i == current;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () => onPick(i),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: selected ? colors.primary : colors.border),
                  ),
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? colors.onPrimary : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
