import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/repositories/kitchen_repository_firestore.dart';
import '../../domain/models/kitchen_order.dart';
import '../../domain/repositories/kitchen_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final kitchenRepositoryProvider = Provider<KitchenRepository>((ref) {
  ref.watch(firestoreProvider); // ensures Firestore is ready
  return KitchenRepositoryFirestore();
});

// ── Orders stream ─────────────────────────────────────────────────────────────

final kitchenOrdersProvider = StreamProvider<List<KitchenOrder>>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) return const Stream.empty();

  final repo = ref.watch(kitchenRepositoryProvider);
  return repo.watchOrders(
    locationId: session.locationId,
    stationId: session.stationId?.isNotEmpty == true ? session.stationId : null,
  );
});

// ── Stations ──────────────────────────────────────────────────────────────────

final kitchenStationsProvider = FutureProvider<List<KitchenStation>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return [];
  final repo = ref.watch(kitchenRepositoryProvider);
  return repo.getStations(session.locationId);
});

// ── Bumped / recalled orders ──────────────────────────────────────────────────

final bumpedOrdersProvider = FutureProvider<List<KitchenOrder>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return [];
  final repo = ref.watch(kitchenRepositoryProvider);
  return repo.getBumpedOrders(locationId: session.locationId);
});

// ── Display preferences (persisted) ──────────────────────────────────────────

const _kColCount = 'kds_column_count';
const _kViewMode = 'kds_view_mode';

enum KdsViewMode { grid, tableView, expoView }

final columnCountProvider = StateNotifierProvider<ColumnCountNotifier, int>(
  (ref) => ColumnCountNotifier(),
);

class ColumnCountNotifier extends StateNotifier<int> {
  ColumnCountNotifier() : super(3) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getInt(_kColCount) ?? 3;
  }

  Future<void> set(int count) async {
    state = count;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kColCount, count);
  }
}

final viewModeProvider = StateNotifierProvider<ViewModeNotifier, KdsViewMode>(
  (ref) => ViewModeNotifier(),
);

class ViewModeNotifier extends StateNotifier<KdsViewMode> {
  ViewModeNotifier() : super(KdsViewMode.grid) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt(_kViewMode) ?? 0;
    state = KdsViewMode.values[idx.clamp(0, KdsViewMode.values.length - 1)];
  }

  Future<void> cycle() async {
    final next = KdsViewMode.values[
        (state.index + 1) % KdsViewMode.values.length];
    state = next;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kViewMode, next.index);
  }
}

// ── New-order alert ───────────────────────────────────────────────────────────

/// Set of known order IDs — used to detect new arrivals and trigger the alert.
final knownOrderIdsProvider = StateProvider<Set<String>?>((ref) => null);
