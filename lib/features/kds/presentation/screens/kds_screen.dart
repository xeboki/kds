import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kds_theme.dart';
import '../../domain/models/kitchen_order.dart';
import '../../../auth/domain/models/kds_session.dart';
import '../providers/kitchen_providers.dart';
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
      appBar: _buildAppBar(context, session, viewMode, colCount),
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
                      routingCategoryIds:
                          session?.routingCategoryIds ?? const [],
                      isExpo: session?.isExpo ?? false);
                case KdsViewMode.tableView:
                  return _TableConsolidatedView(
                      orders: orders,
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
          tooltip: 'Columns ($colCount)',
          icon: Icon(Icons.settings, color: colors.textSecondary),
          onPressed: () => _showColumnPicker(context, colCount),
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

  void _showColumnPicker(BuildContext context, int current) {
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
            Text('Columns',
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2, 3, 4, 5].map((n) {
                final selected = n == current;
                return GestureDetector(
                  onTap: () {
                    ref.read(columnCountProvider.notifier).set(n);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary
                          : colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(
                          color: selected ? colors.onPrimary : colors.textSecondary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grid view ──────────────────────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  const _GridView({
    required this.orders,
    required this.colCount,
    this.routingCategoryIds = const [],
    this.isExpo = false,
  });
  final List<KitchenOrder> orders;
  final int colCount;

  /// Passed down so a card shows only the lines this screen is responsible
  /// for. SPEC-097, Square's model.
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: orders.length,
      itemBuilder: (_, i) => OrderCard(
          order: orders[i],
          routingCategoryIds: routingCategoryIds,
          isExpo: isExpo),
    );
  }
}

// ── Table-consolidated view ────────────────────────────────────────────────────

class _TableConsolidatedView extends StatelessWidget {
  const _TableConsolidatedView({
    required this.orders,
    this.routingCategoryIds = const [],
    this.isExpo = false,
  });
  final List<KitchenOrder> orders;

  /// The table view is still this screen's board, grouped by table rather
  /// than by ticket.
  final List<String> routingCategoryIds;
  final bool isExpo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final byTable = <String, List<KitchenOrder>>{};
    for (final o in orders) {
      final key = o.tableNumber ?? 'No Table';
      byTable.putIfAbsent(key, () => []).add(o);
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: byTable.entries.map((e) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Table ${e.key}',
                style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1),
              ),
            ),
            SizedBox(
              height: 320,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: e.value
                    .map((o) => SizedBox(
                          width: 260,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: OrderCard(
                                order: o,
                                routingCategoryIds: routingCategoryIds,
                                isExpo: isExpo),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Divider(color: colors.border),
          ],
        );
      }).toList(),
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
                  'T${entry.order.tableNumber}',
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
