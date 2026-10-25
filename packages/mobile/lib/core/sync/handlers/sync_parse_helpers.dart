/// Parsing helpers for sync handler fromSyncPayload methods.
///
/// A value that can't be read throws a [FormatException]. The sync engine
/// then skips that row and pulls it again later; inventing 0.0 or "now"
/// would save a wrong amount or date for good.
library;

import 'package:expense_tracker/core/utils/money.dart';

/// [value] as an amount rounded to 2 decimals (ADR 0014).
double parseSyncAmount(Object? value) {
  final amount = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value),
    _ => null,
  };
  if (amount == null || !amount.isFinite) {
    throw FormatException('Unreadable sync amount (${value.runtimeType})');
  }

  return roundMoney(amount);
}

/// [value] as a local [DateTime].
DateTime parseSyncDate(Object? value) {
  final date = switch (value) {
    DateTime() => value,
    String() => DateTime.tryParse(value),
    _ => null,
  };
  if (date == null) {
    throw FormatException('Unreadable sync date (${value.runtimeType})');
  }

  return date.toLocal();
}

String parseSyncString(Object? value, [String fallback = '']) {
  if (value is String) return value;
  if (value != null) return value.toString();

  return fallback;
}
