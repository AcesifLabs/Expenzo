library;

import 'package:expense_tracker/core/utils/money.dart';

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
