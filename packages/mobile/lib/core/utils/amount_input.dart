import 'package:flutter/services.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';

// A half-typed "12." or ".5" still counts, so the value doesn't drop to 0
// while the user is mid-way through typing it.
final _amountPattern = RegExp(r'^(\d+\.?\d{0,2}|\.\d{1,2})$');

final _maxWholeDigits = AppConstants.maxAmount.truncate().toString().length;

/// Lets an amount field take up to [AppConstants.maxAmount] with at most
/// two decimals.
final amountInputFormatter = FilteringTextInputFormatter.allow(
  RegExp('^\\d{0,$_maxWholeDigits}(\\.\\d{0,2})?'),
);

const _banglaZero = 0x09E6;

String latinDigits(String text) => String.fromCharCodes(
  text.runes.map(
    (r) => r >= _banglaZero && r <= _banglaZero + 9
        ? '0'.codeUnitAt(0) + r - _banglaZero
        : r,
  ),
);

double? parseAmountInput(String text) {
  final latin = latinDigits(text.trim()).replaceAll(RegExp(r'[,\s]'), '');
  if (!_amountPattern.hasMatch(latin)) return null;
  final amount = double.parse(latin);

  return amount > AppConstants.maxAmount ? null : amount;
}
