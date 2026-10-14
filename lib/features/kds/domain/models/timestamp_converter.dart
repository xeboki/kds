/// Reading a date that Firestore may have stored three different ways.
///
/// SPEC-097 097-A. A `kitchen_orders` document does not hold one kind of date.
/// Fields the model itself writes go through `toJson()` and land as **ISO-8601
/// strings**; fields a repository stamps by hand land as a Firestore
/// **`Timestamp`**, because `FieldValue.serverTimestamp()` is the only way to
/// get the server's clock rather than a till's — and tills drift.
///
/// The generated reader assumes one type and calls `DateTime.parse` on it, so
/// the moment a hand-stamped field is read back it throws:
///
///   > Could not create `_$KitchenOrderImpl`. There is a problem with
///   > "bumped_at". type 'Timestamp' is not a subtype of type 'String'
///
/// Which is exactly what the recall panel showed the first time its query
/// matched anything. The failure is total — one unreadable field throws the
/// whole document away, so a single `bumped_at` took down the entire list.
///
/// The alternative was to write ISO strings and keep the reader naive. That
/// loses the server clock, and it would not fix the documents already written,
/// which are a mixture either way. Accepting all three forms is the only
/// version that can read what is actually in the database today.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Always returns UTC.
///
/// The three forms disagree about it otherwise: `Timestamp.toDate()` hands
/// back a **local** `DateTime`, while `DateTime.parse` of an ISO string ending
/// in `Z` hands back a **UTC** one. Same instant, different `isUtc` flag — so
/// `difference()` stays right while anything reading `.hour` silently shifts
/// by the offset, depending on which writer happened to stamp the field.
/// Normalising here means a reader never has to know which it got; anything
/// displaying a wall-clock time calls `.toLocal()` itself.
DateTime? _read(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toUtc();
  if (value is DateTime) return value.toUtc();
  if (value is String) return DateTime.tryParse(value)?.toUtc();
  // An int is milliseconds since the epoch — some older rows hold one.
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  return null;
}

/// For nullable `DateTime?` fields.
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) => _read(json);

  /// Written back as ISO-8601, which is what every other field of this model
  /// serialises to. A `Timestamp` only ever enters through a hand-written
  /// `serverTimestamp()`, never through here.
  @override
  Object? toJson(DateTime? value) => value?.toIso8601String();
}

/// For required `DateTime` fields.
///
/// A required date that cannot be read is a broken document rather than a
/// missing value, so this throws instead of quietly substituting `now` — a
/// ticket dated to the moment it was read looks brand new on the board, which
/// is the one thing a kitchen screen must never get wrong.
class RequiredTimestampConverter implements JsonConverter<DateTime, Object?> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    final value = _read(json);
    if (value == null) {
      throw FormatException('Not a date this app can read: $json');
    }
    return value;
  }

  @override
  Object? toJson(DateTime value) => value.toIso8601String();
}
