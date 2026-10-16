import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/domain/models/kitchen_order.dart';
import 'package:xeboki_kds/features/kds/domain/ticket_fit.dart';

KitchenOrderItem _item(String name, {int? course}) => KitchenOrderItem(
      id: name,
      orderId: 'o1',
      productId: 'p-$name',
      productName: name,
      quantity: 1,
      status: KitchenItemStatus.pending,
      courseNumber: course,
    );

Map<int, List<KitchenOrderItem>> _courses(Map<int, int> counts) => {
      for (final e in counts.entries)
        e.key: [
          for (var i = 0; i < e.value; i++) _item('c${e.key}i$i', course: e.key)
        ]
    };

void main() {
  group('rowsNeeded charges for course headings', () {
    test('one course is drawn without a heading, so costs only its lines', () {
      expect(rowsNeeded(_courses({1: 5})), 5);
    });

    test('three courses cost their lines plus three headings', () {
      expect(rowsNeeded(_courses({1: 2, 2: 3, 3: 1})), 6 + 3);
    });

    test('an empty ticket needs no rows', () {
      expect(rowsNeeded(<int, List<KitchenOrderItem>>{}), 0);
    });
  });

  group('fitTicket', () {
    test('a whole ticket inside its budget hides nothing', () {
      final fit = fitTicket(_courses({1: 3}), rowBudget: 10);
      expect(fit.itemsShown, 3);
      expect(fit.itemsHidden, 0);
      expect(fit.hidesAnything, isFalse);
    });

    test('a null budget draws everything — the sheet may scroll', () {
      final fit = fitTicket(_courses({1: 40, 2: 40}), rowBudget: null);
      expect(fit.itemsShown, 80);
      expect(fit.itemsHidden, 0);
    });

    test('an over-long single course spends one row on the notice', () {
      // 10 lines, 6 rows: 5 drawn, the 6th row says "+5 more".
      final fit = fitTicket(_courses({1: 10}), rowBudget: 6);
      expect(fit.itemsShown, 5);
      expect(fit.itemsHidden, 5);
      expect(fit.perCourseShown[1], 5);
    });

    test('a coursed ticket is truncated, and headings are paid for', () {
      // 3 courses of 4 = 12 lines + 3 headings = 15 rows, budget 8.
      // 7 usable: heading+4 (course 1) leaves 2, heading+1 (course 2) leaves 0.
      final fit = fitTicket(_courses({1: 4, 2: 4, 3: 4}), rowBudget: 8);
      expect(fit.perCourseShown[1], 4);
      expect(fit.perCourseShown[2], 1);
      expect(fit.perCourseShown[3], isNull);
      expect(fit.itemsShown, 5);
      expect(fit.itemsHidden, 7);
    });

    test('the drawn rows never exceed the budget', () {
      for (var budget = 2; budget <= 20; budget++) {
        for (final counts in [
          {1: 9},
          {1: 3, 2: 3},
          {1: 1, 2: 1, 3: 1, 4: 1, 5: 1},
          {1: 12, 2: 1},
        ]) {
          final byCourse = _courses(counts);
          final fit = fitTicket(byCourse, rowBudget: budget);
          final headed = byCourse.length > 1;
          final drawn = fit.perCourseShown.entries
              .where((e) => e.value > 0)
              .fold<int>(0, (sum, e) => sum + e.value + (headed ? 1 : 0));
          final rows = fit.hidesAnything ? drawn + 1 : drawn;
          expect(rows, lessThanOrEqualTo(budget),
              reason: 'budget $budget, courses $counts overflowed its slot');
        }
      }
    });

    test('a heading is never drawn with none of its lines under it', () {
      final fit = fitTicket(_courses({1: 5, 2: 5}), rowBudget: 8);
      for (final shown in fit.perCourseShown.values) {
        expect(shown, greaterThan(0));
      }
    });

    test('shown and hidden always account for every line', () {
      for (var budget = 2; budget <= 15; budget++) {
        final byCourse = _courses({1: 4, 2: 4, 3: 4});
        final fit = fitTicket(byCourse, rowBudget: budget);
        expect(fit.itemsShown + fit.itemsHidden, 12,
            reason: 'budget $budget lost or invented a line');
      }
    });
  });
}
