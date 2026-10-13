/// The kitchen screen wears the till's clothes.
///
/// SPEC-097. This app had its own four-colour palette and a hardcoded dark
/// `ThemeData`, invented separately from Pro's — the same product in two
/// design systems, with no way to tell which was current when either moved.
///
/// The theme files here are **copies of Pro's**, so the test that matters is
/// not "do they look nice" but "are they still the same file". A copy nobody
/// compares is a fork.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Pro's theme directory, beside this app in the monorepo.
Directory get _proTheme =>
    Directory('../Pro/lib/core/theme');

const _shared = [
  'app_colors.dart',
  'app_text_styles.dart',
  'app_spacing.dart',
  'app_theme.dart',
];

/// The source of the call enclosing [at], climbed [levels] times.
///
/// Walks back to the nearest unclosed `(` and forward to its partner, so the
/// span returned is one whole widget call rather than a guessed number of
/// characters. Returns an empty string if the parentheses do not balance,
/// which makes a malformed file report nothing rather than report nonsense.
String _enclosingCall(String source, int at, int levels) {
  var start = at;
  for (var level = 0; level < levels; level++) {
    var depth = 0;
    var open = -1;
    for (var j = start - 1; j >= 0; j--) {
      final c = source[j];
      if (c == ')') {
        depth++;
      } else if (c == '(') {
        if (depth == 0) {
          open = j;
          break;
        }
        depth--;
      }
    }
    if (open < 0) return '';
    start = open;
  }
  var depth = 0;
  for (var j = start; j < source.length; j++) {
    final c = source[j];
    if (c == '(') {
      depth++;
    } else if (c == ')') {
      depth--;
      if (depth == 0) return source.substring(start, j + 1);
    }
  }
  return '';
}

void main() {
  final skip = _proTheme.existsSync()
      ? null
      : 'POS/Pro is not checked out beside KDS';

  group('the theme is the till\'s', () {
    test('the sweep can see both copies', () {
      // A comparison against a directory that is not there passes silently,
      // which is exactly how two copies drift.
      for (final name in _shared) {
        expect(File('lib/core/theme/$name').existsSync(), isTrue,
            reason: '$name is missing from this app');
      }
    });

    test('every shared theme file is byte-identical to Pro\'s', () {
      final drifted = <String>[];
      for (final name in _shared) {
        final mine = File('lib/core/theme/$name').readAsStringSync();
        final theirs = File('${_proTheme.path}/$name').readAsStringSync();
        if (mine != theirs) drifted.add(name);
      }
      expect(drifted, isEmpty,
          reason: 'these have diverged from Pro, so the two apps no longer '
              'agree on what the product looks like. Copy Pro\'s version '
              'rather than editing this one: ${drifted.join(', ')}');
    }, skip: skip);

    test('no screen keeps a palette of its own', () {
      // The old `KdsTheme.surface` / `.ageRed` constants. Anything still
      // naming a colour here is a second source for it.
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.contains('/core/theme/')) continue;
        final source = entity.readAsStringSync();
        // `Color(0x…)` AND the dark-mode shorthands. Checking only the
        // hex literal is what let this through the first time: every
        // screen was full of `Colors.white54`, written when the app was
        // always dark. On the till's light ground the login title was
        // white on near-white — legible in neither theme by accident.
        for (final m in RegExp(
                r'Color\(0x[0-9a-fA-F]{8}\)|Colors\.(?:white|black)[0-9]*')
            .allMatches(source)) {
          offenders.add('${entity.path}: ${m.group(0)}');
        }
      }
      expect(offenders, isEmpty,
          reason: 'a colour named outside the theme is a colour the till '
              'cannot change:\n  ${offenders.join('\n  ')}');
    });

    test('the kitchen palette is derived, not picked again', () {
      // Age, priority and status are the one thing Pro has no role for. They
      // must still come OFF Pro's roles, or the kitchen's "late" stops
      // being the same amber as every other warning in the product.
      final kds = File('lib/core/theme/kds_theme.dart').readAsStringSync();
      expect(kds, isNot(contains('Color(0x')),
          reason: 'the kitchen palette names a literal colour again');
      for (final role in ['_c.success', '_c.warning', '_c.error', '_c.info']) {
        expect(kds, contains(role),
            reason: 'the kitchen ramp no longer derives from $role');
      }
    });

    test('ink on a saturated fill is on-primary, never body text', () {
      // The second half of the same mistake. Mapping every `Colors.white`
      // to `textPrimary` is right on a surface and wrong on a fill: in the
      // light theme `textPrimary` is slate-900, so "Sign In" and the
      // selected column chip came out near-black on Pro's blue, and BUMP
      // would have on the ready-green. `onPrimary` is the role that already
      // flips with the theme — white on light, dark ink on dark.
      //
      // A fill counts as saturated when it is `colors.primary` or one of
      // the kitchen ramp's solids, at full opacity. The tinted variants
      // (`.withValues(alpha: …)`) are backgrounds, not fills, and are
      // deliberately excluded — they carry their own colour as ink.
      //
      // A fill is written two ways here and the guard has to see both, because
      // the two real defects were one of each: `backgroundColor:` on a button
      // (Sign In) and `color:` inside a `BoxDecoration` (the column chip). A
      // version of this test that only matched `foregroundColor:` passed while
      // the chip was still unreadable.
      const saturated =
          r'(?:colors\.primary|kitchen\.(?:status|priority|age)[A-Za-z]+)'
          r'(?![.\w])';
      final offenders = <String>[];
      final fills = [
        RegExp(r'backgroundColor:\s*(?:[^,;]*\?\s*)?' + saturated, dotAll: true),
        RegExp(r'BoxDecoration\([^;]{0,160}?color:\s*(?:[^,;]*\?\s*)?' + saturated,
            dotAll: true),
      ];
      // The first colour declared after the fill, whichever form it takes.
      final ink = RegExp(
          r'(?:foregroundColor:|TextStyle\([^)]{0,220}?color:)'
          r'\s*(?:[^,;]*\?\s*)?colors\.(\w+)',
          dotAll: true);
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        for (final fill in fills) {
          for (final f in fill.allMatches(source)) {
            // Only text INSIDE the filled widget sits on the fill. A fixed
            // character window does not know that: it read past the end of a
            // 10×10 status dot — a `Container` with a colour and no child at
            // all — into the next widget's label, and reported a dot for
            // having unreadable text on it. So climb to the enclosing call
            // (`BoxDecoration(` → its `Container(`, `backgroundColor:` → its
            // `styleFrom(`, which is where a button's label colour lives)
            // by matching parentheses, and search only within that span.
            final window = _enclosingCall(source, f.start, 1);
            final i = ink.firstMatch(window);
            if (i == null || i.group(1) == 'onPrimary') continue;
            final line = '\n'.allMatches(source.substring(0, f.start)).length + 1;
            offenders.add('${entity.path}:$line: colors.${i.group(1)} '
                'on ${f.group(0)!.split(RegExp(r'\s+')).last}');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'text on a coloured fill must use the on-primary role, or '
              'it is unreadable in one of the two themes:\n  '
              '${offenders.join('\n  ')}');
    });

    test('the app offers both of the till\'s themes', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('AppTheme.light()'));
      expect(main, contains('AppTheme.dark()'));
      expect(main, isNot(contains('KdsTheme.dark')),
          reason: 'still building its own ThemeData');
    });
  });

  group('the mark is the till\'s', () {
    test('every icon is byte-identical to Pro\'s', () {
      final icons = [
        'web/favicon.png',
        'web/icons/Icon-192.png',
        'web/icons/Icon-512.png',
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
      ];
      final drifted = <String>[];
      for (final rel in icons) {
        final mine = File(rel);
        final theirs = File('../Pro/$rel');
        if (!theirs.existsSync()) continue;
        if (!mine.existsSync() ||
            mine.readAsBytesSync().toString() !=
                theirs.readAsBytesSync().toString()) {
          drifted.add(rel);
        }
      }
      expect(drifted, isEmpty,
          reason: 'these differ from Pro, so the kitchen screen wears a '
              'different mark from the till: ${drifted.join(', ')}');
    }, skip: skip);
  });
}
