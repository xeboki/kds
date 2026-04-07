import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/kitchen_order.dart';
import '../providers/kitchen_providers.dart';
import '../widgets/order_card.dart';
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
      backgroundColor: KdsTheme.surface,
      appBar: _buildAppBar(context, session, viewMode, colCount),
      body: Stack(
        children: [
          ordersAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: KdsTheme.primary)),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: KdsTheme.ageRed)),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return const _EmptyBoard();
              }
              switch (viewMode) {
                case KdsViewMode.grid:
                  return _GridView(orders: orders, colCount: colCount);
                case KdsViewMode.tableView:
                  return _TableConsolidatedView(orders: orders);
                case KdsViewMode.expoView:
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_active,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'NEW ORDER',
                      style: TextStyle(
                          color: Colors.white,
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
    dynamic session,
    KdsViewMode viewMode,
    int colCount,
  ) {
    return AppBar(
      backgroundColor: KdsTheme.surface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kitchen Display',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (session != null)
            Text(
              session.locationName +
                  (session.stationId != null ? ' · ${session.stationId}' : ''),
              style:
                  const TextStyle(fontSize: 11, color: Colors.white54),
            ),
        ],
      ),
      actions: [
        // View mode toggle
        IconButton(
          tooltip: 'Toggle view',
          icon: Icon(
            viewMode == KdsViewMode.grid
                ? Icons.grid_view_rounded
                : viewMode == KdsViewMode.tableView
                    ? Icons.table_restaurant
                    : Icons.list_alt_rounded,
            color: Colors.white70,
          ),
          onPressed: () =>
              ref.read(viewModeProvider.notifier).cycle(),
        ),

        // Column count picker
        IconButton(
          tooltip: 'Columns ($colCount)',
          icon: const Icon(Icons.settings, color: Colors.white70),
          onPressed: () => _showColumnPicker(context, colCount),
        ),

        // Logout
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout, color: Colors.white38),
          onPressed: () async {
            await ref.read(sessionProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
        ),
      ],
    );
  }

  void _showColumnPicker(BuildContext context, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KdsTheme.surfaceCard,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Columns',
                style: TextStyle(
                    color: Colors.white,
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
                          ? KdsTheme.primary
                          : KdsTheme.surfaceLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.white54,
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
  const _GridView({required this.orders, required this.colCount});
  final List<KitchenOrder> orders;
  final int colCount;

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
      itemBuilder: (_, i) => OrderCard(order: orders[i]),
    );
  }
}

// ── Table-consolidated view ────────────────────────────────────────────────────

class _TableConsolidatedView extends StatelessWidget {
  const _TableConsolidatedView({required this.orders});
  final List<KitchenOrder> orders;

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                    color: Colors.white54,
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
                            child: OrderCard(order: o),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Divider(color: Colors.white12),
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
          const Divider(color: Colors.white12, height: 1),
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
                  color: KdsTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${entry.order.orderNumber}',
                  style: const TextStyle(
                      color: Colors.white70,
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.item.status == KitchenItemStatus.completed
                      ? KdsTheme.statusReady
                      : entry.item.status == KitchenItemStatus.preparing
                          ? KdsTheme.statusPreparing
                          : KdsTheme.statusPending,
                ),
              ),
              const SizedBox(width: 8),
              // Table tag
              if (entry.order.tableNumber != null)
                Text(
                  'T${entry.order.tableNumber}',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 12),
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, size: 64, color: Colors.white12),
          SizedBox(height: 16),
          Text(
            'No active orders',
            style: TextStyle(color: Colors.white38, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
