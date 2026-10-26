import 'package:expense_tracker/core/constants/app_constants.dart';

final _amountPattern = RegExp(r'^\d+(\.\d{1,2})?$');

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
