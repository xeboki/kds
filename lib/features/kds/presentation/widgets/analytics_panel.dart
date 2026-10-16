/// How the kitchen is doing, right now.
///
/// SPEC-097 097-A, ported from the till's own Kitchen Display. Everything here
/// is derived from the two streams the board already watches — there is no new
/// query and no stored metric, so it cannot disagree with the cards on screen.
///
/// It answers the questions a head chef asks across a service without counting
/// tickets by eye: how many are open, how long the oldest have been waiting,
/// how much went out in the last hour, and whether the board is backed up at
/// one status. A screen that only ever shows *the current tickets* makes all
/// of those invisible.
///
/// The numbers are scoped to **this screen**: `kitchenOrdersProvider` already
/// filters to the routing categories this screen is switched on for, so a
/// grill screen reports the grill's backlog rather than the whole kitchen's.
/// That is the right answer for the person standing in front of it; an expo
/// screen sees everything and so reports the pass.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kds_theme.dart';
import '../../domain/models/kitchen_order.dart';
import '../providers/kitchen_providers.dart';

Future<void> showAnalyticsPanel(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AnalyticsPanel(),
    );

class AnalyticsPanel extends ConsumerWidget {
  const AnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final orders = ref.watch(kitchenOrdersProvider);
    final bumped = ref.watch(bumpedOrdersProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                  Icon(Icons.bar_chart, color: colors.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Kitchen analytics',
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
              child: orders.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Could not read the board — $e',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.kitchen.ageRed)),
                  ),
                ),
                data: (active) => _Body(
                  active: active,
                  bumped: bumped.valueOrNull ?? const [],
                  scrollCtrl: scrollCtrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.active,
    required this.bumped,
    required this.scrollCtrl,
  });

  final List<KitchenOrder> active;
  final List<KitchenOrder> bumped;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Orders not due yet are dropped, not clamped: their wait is negative,
    // and one pre-order for tonight would otherwise pull the average below
    // zero and make the oldest ticket look fresher than it is.
    final waits = active
        .where((o) => !o.isScheduledAhead)
        .map((o) => o.waitTimeMinutes)
        .toList();
    final avgWait =
        waits.isEmpty ? 0 : waits.reduce((a, b) => a + b) ~/ waits.length;
    // The oldest ticket is the one a customer is actually waiting on, and an
    // average hides it: four fresh tickets and one twenty-five minutes old
    // average out to looking fine.
    final oldest = waits.isEmpty ? 0 : waits.reduce((a, b) => a > b ? a : b);

    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 1));
    final bumpedRecent = bumped
        .where((o) => o.bumpedAt != null && o.bumpedAt!.isAfter(cutoff))
        .length;
    // Counted from `recalledAt`, not from how many recalled tickets happen to
    // be on the board. Those are different numbers — a ticket recalled this
    // morning is still sitting there with status `recalled` — and putting the
    // board count under a "last hour" heading would have been a label that
    // quietly means something else.
    final recalledRecent = active
        .where((o) =>
            o.status == KitchenOrderStatus.recalled &&
            o.recalledAt != null &&
            o.recalledAt!.isAfter(cutoff))
        .length;

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(20),
      children: [
        _heading(context, 'WAITING'),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
              label: 'Longest wait',
              value: '${oldest}m',
              color: _waitColour(context, oldest),
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Average wait',
              value: '${avgWait}m',
              color: _waitColour(context, avgWait),
            ),
            const SizedBox(width: 12),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 24),
        _heading(context, 'LAST HOUR'),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
                label: 'Bumped',
                value: '$bumpedRecent',
                color: colors.success),
            const SizedBox(width: 12),
            // Deliberately paired with the bump count. A recall is a mistake
            // being undone or a plate coming back, and seeing it next to what
            // went out is the only way the number means anything.
            _StatCard(
              label: 'Recalled',
              value: '$recalledRecent',
              color: colors.error,
            ),
            const SizedBox(width: 12),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Color _waitColour(BuildContext context, int minutes) {
    final kitchen = context.kitchen;
    if (minutes >= 25) return kitchen.ageUrgent;
    if (minutes >= 15) return kitchen.ageRed;
    if (minutes >= 8) return kitchen.ageAmber;
    return kitchen.ageOk;
  }

  Widget _heading(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: context.appColors.textSecondary,
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

