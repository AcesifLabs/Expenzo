import 'package:expense_tracker/core/constants/app_constants.dart';

final _amountPattern = RegExp(r'^\d+(\.\d{1,2})?$');

/// Bangla digits ০–৯ (U+09E6–U+09EF).
const _banglaZero = 0x09E6;

/// Reads an amount typed in Latin or Bangla digits, with optional thousands
/// commas. Returns null when empty, not a number, negative, more than 2
/// decimals, or above [AppConstants.maxAmount].
double? parseAmountInput(String text) {
  final latin = String.fromCharCodes(
    text.trim().runes.map(
      (r) => r >= _banglaZero && r <= _banglaZero + 9
          ? '0'.codeUnitAt(0) + r - _banglaZero
          : r,
    ),
  ).replaceAll(RegExp(r'[,\s]'), '');
  if (!_amountPattern.hasMatch(latin)) return null;
  final amount = double.parse(latin);

  return amount > AppConstants.maxAmount ? null : amount;
}
