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
    // The screen's own switches, and whether it is the pass. An expo screen
    // carries categories and ignores them — it assembles the whole order.
    routingCategoryIds: session.routingCategoryIds,
    isExpo: session.isExpo,
  );
});


// ── Bumped / recalled orders ──────────────────────────────────────────────────

/// The tickets a cook can pull back, re-read every time the panel opens.
///
/// `autoDispose` is load-bearing. As a plain `FutureProvider` this held its
/// first answer for the life of the app: open the recall panel once at the
/// start of service, when nothing has been bumped, and it cached an empty
/// list — so every later bump was unrecallable and the panel said "Nothing
/// has been bumped yet" while the ticket sat in Firestore with its
/// `bumped_at` set. Proven on 34: bumped DET00005, panel still empty.
final bumpedOrdersProvider =
    FutureProvider.autoDispose<List<KitchenOrder>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return [];
  final repo = ref.watch(kitchenRepositoryProvider);
  return repo.getBumpedOrders(locationId: session.locationId);
});

// ── Display preferences (persisted) ──────────────────────────────────────────

const _kColCount = 'kds_column_count';
const _kTicketSize = 'kds_ticket_size';
const _kViewMode = 'kds_view_mode';

/// How the board is read.
///
/// `allDay` is Square's and Toast's own fourth view: not the tickets, but how
/// much of each thing is still to be made across all of them. It is the view a
/// cook batches from.
enum KdsViewMode { grid, tableView, expoView, allDay }

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

/// How big a ticket's text is: 0 small, 1 medium, 2 large.
///
/// Not "rows". How many tickets fit in a column is the screen's business, not
/// a number somebody types — a board holds what it holds. What a kitchen
/// genuinely wants to choose is how big the writing is, which then decides how
/// much fits. Toast offers the same control as Small / Medium / Large.
final ticketSizeProvider = StateNotifierProvider<TicketSizeNotifier, int>(
  (ref) => TicketSizeNotifier(),
);

class TicketSizeNotifier extends StateNotifier<int> {
  TicketSizeNotifier() : super(1) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = (p.getInt(_kTicketSize) ?? 1).clamp(0, 2);
  }

  Future<void> set(int size) async {
    state = size.clamp(0, 2);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kTicketSize, state);
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
