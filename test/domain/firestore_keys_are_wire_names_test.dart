/// Every Firestore key this app writes or queries must be the *wire* name.
///
/// SPEC-097 097-A. `build.yaml` sets `field_rename: snake`, so a model that
/// declares `bumpedAt` reads and writes `bumped_at`. Nothing enforces that on
/// the way out: a repository is free to `update({'bumpedAt': …})`, and
/// Firestore accepts it — it simply stores a *second*, different field that no
/// model has ever read.
///
/// That is how recall was dead on both apps. `bumpOrder` stamped `bumpedAt`;
/// `getBumpedOrders` ordered by `bumped_at`; **Firestore drops documents that
/// lack the field you order by**, so the query matched nothing, every time,
/// and the panel said "Nothing has been bumped yet" directly underneath a
/// board that had just bumped a ticket. Five timestamps were written this way
/// here and five in the till, which also left `prepTimeMinutes` — ready minus
/// started — permanently null.
///
/// Nothing errors in any of it. The write succeeds, the read succeeds, and the
/// feature is simply absent.
///
/// The dictionary is **derived, not listed**. `json_serializable` emits a
/// `fieldKeyMap` into every `.g.dart` under `checked: true`, mapping each Dart
/// field to the key it is actually stored under. This reads those, so a model
/// gaining a field needs no edit here — and the failure can name the spelling
/// that was meant, because the generator already worked it out.
///
/// Scope is the other half of being useful. A name like `customerName` is a
/// renamed field on *some* model and a perfectly ordinary map key everywhere
/// else — a contract template, an API payload, a widget's arguments. Matching
/// on the name alone reported 553 lines in the till, almost none of them real,
/// which is a guard nobody can act on. So a literal counts only when it can be
/// shown to reach Firestore: the call *enclosing* it is a write or a query,
/// found by matching parentheses backwards rather than by looking a fixed
/// distance up the file.
///
/// That alone is not enough, and the first version of this test proved it by
/// passing a deliberate re-break of the exact bug above. A repository rarely
/// writes an inline map — it builds one in a local (`data['bumped_at'] = now;`)
/// across a switch and passes it to `update(data)` at the end, so the call
/// enclosing the key is nothing at all. So the variables a file hands to a
/// write are collected first, and keys assigned into *those* count too.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `'dartName': 'wire_name',` inside a generated `fieldKeyMap`.
final _mapEntry = RegExp(r"'([A-Za-z0-9_]+)'\s*:\s*'([A-Za-z0-9_]+)'");

/// A string literal used as a field name: a map key, or an index assignment.
final _keyUse = RegExp(
  r"'([A-Za-z0-9_]+)'\s*:"
  r"|\[\s*'([A-Za-z0-9_]+)'\s*\]\s*=",
);

/// A query naming a field directly. Unambiguous — no enclosing call needed.
final _queryUse =
    RegExp(r"\.(?:where|orderBy)\(\s*'([A-Za-z0-9_]+)'");

/// The calls whose arguments are Firestore field names.
const _firestoreCalls = {'set', 'update', 'add', 'where', 'orderBy'};

/// `update(data)` / `set(payload, …)` — the local a file hands to a write.
final _payloadArgument =
    RegExp(r'\.(?:set|update|add)\(\s*([a-z][A-Za-z0-9_]*)\s*[,)]');

bool _generated(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

List<File> _dartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Dart field name → the key it is really stored under, for every field whose
/// two spellings differ.
Map<String, String> _renamedFields() {
  final renamed = <String, String>{};
  for (final file in _dartFiles().where((f) => _generated(f.path))) {
    final source = file.readAsStringSync();
    var index = source.indexOf('fieldKeyMap');
    while (index != -1) {
      final open = source.indexOf('{', index);
      final close = source.indexOf('}', open);
      if (open == -1 || close == -1) break;
      for (final match in _mapEntry.allMatches(source.substring(open, close))) {
        final dartName = match.group(1)!;
        final wireName = match.group(2)!;
        if (dartName != wireName) renamed[dartName] = wireName;
      }
      index = source.indexOf('fieldKeyMap', close);
    }
  }
  return renamed;
}

/// The name of the call whose argument list [offset] sits inside.
///
/// Walks backwards counting brackets, so it finds the call that actually
/// encloses this literal however many lines up it is — a fixed-size window
/// either misses `update({` three lines above or claims a call that closed
/// before the literal began.
String? _enclosingCall(String source, int offset) {
  var depth = 0;
  for (var i = offset - 1; i >= 0; i--) {
    final c = source[i];
    if (c == ')' || c == ']' || c == '}') {
      depth++;
    } else if (c == '(' || c == '[' || c == '{') {
      if (depth == 0) {
        if (c != '(') continue; // a map or list literal — keep going out
        var end = i;
        var start = i;
        while (start > 0 &&
            RegExp(r'[A-Za-z0-9_]').hasMatch(source[start - 1])) {
          start--;
        }
        return start < end ? source.substring(start, end) : null;
      }
      depth--;
    }
  }
  return null;
}

void main() {
  test('the generated field maps were found at all', () {
    // Without this the sweep below passes by reading nothing — the shape of
    // failure this repo keeps producing. If code generation has not been run,
    // or `checked: true` is dropped from build.yaml, say so here rather than
    // reporting a clean sweep of an empty dictionary.
    final renamed = _renamedFields();
    expect(renamed, isNotEmpty,
        reason: 'No fieldKeyMap found in any .g.dart — run build_runner.');
    expect(renamed['bumpedAt'], 'bumped_at');
  });

  test('no Firestore key is written or queried under its Dart name', () {
    final renamed = _renamedFields();
    final offences = <String>[];

    void report(File file, String source, int offset, String name) {
      final wire = renamed[name];
      if (wire == null) return;
      final line = '\n'.allMatches(source.substring(0, offset)).length + 1;
      final text = source.split('\n')[line - 1].trim();
      offences.add("${file.path}:$line  '$name' should be '$wire'  →  $text");
    }

    for (final file in _dartFiles().where((f) => !_generated(f.path))) {
      final source = file.readAsStringSync();

      for (final match in _queryUse.allMatches(source)) {
        report(file, source, match.start, match.group(1)!);
      }
      // The locals this file hands to a Firestore write. Keys assigned into
      // one of these reach the document just as surely as an inline map.
      final payloads = _payloadArgument
          .allMatches(source)
          .map((m) => m.group(1)!)
          .toSet();
      final intoPayload = payloads.isEmpty
          ? null
          : RegExp("(?:${payloads.join('|')})"
              r"\[\s*'([A-Za-z0-9_]+)'\s*\]\s*=");

      for (final match in _keyUse.allMatches(source)) {
        final call = _enclosingCall(source, match.start);
        if (call == null || !_firestoreCalls.contains(call)) continue;
        report(file, source, match.start,
            match.group(1) ?? match.group(2)!);
      }
      if (intoPayload != null) {
        for (final match in intoPayload.allMatches(source)) {
          report(file, source, match.start, match.group(1)!);
        }
      }
    }

    expect(offences, isEmpty,
        reason: 'These reach Firestore under a name no model reads:\n'
            '${offences.join('\n')}');
  });
}
