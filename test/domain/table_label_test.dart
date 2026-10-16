/// A table is called whatever the restaurant calls it.
///
/// The ticket prefixed every table number with a bare `T`, which works for
/// "5" and produces **TB10**, **TWalk 1** and **TTerrace 4** for everything
/// else. Found by ringing a twenty-five table service onto a floor whose
/// sections are Main, Terrace and Bar — the one-table shop this screen was
/// built against never showed it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:xeboki_kds/features/kds/presentation/widgets/order_card.dart';

void main() {
  test('a numbered table keeps the T prefix it was written for', () {
    expect(tableLabel('5'), 'T5');
    expect(tableLabel('12'), 'T12');
  });

  test('a named table is left alone', () {
    expect(tableLabel('B10'), 'B10');
    expect(tableLabel('Walk 1'), 'Walk 1');
    expect(tableLabel('Terrace 4'), 'Terrace 4');
  });

  test('padding does not turn a number into a name', () {
    expect(tableLabel(' 7 '), 'T7');
  });
}
