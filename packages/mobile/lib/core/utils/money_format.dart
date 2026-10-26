import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';

class MoneyFormat {
  final String symbol;
  final int decimalDigits;
  final DigitGrouping grouping;

  static const _numberLocale = 'en';
  static const _commaUnit = 0x2C;
  static const _dotUnit = 0x2E;
  static final _nonZeroDigit = RegExp('[1-9]');

  final NumberFormat _decimalFormat;

  MoneyFormat({
    required this.symbol,
    required this.decimalDigits,
    required this.grouping,
  }) : _decimalFormat = _decimalFormatFor(decimalDigits);

  MoneyFormat.plain({required this.decimalDigits, required this.grouping})
    : symbol = '',
      _decimalFormat = _decimalFormatFor(decimalDigits);

  String format(double amount) {
    final number = _decimalFormat.format(amount.abs());

    return _compose(_isNegative(amount, number) ? '-' : '', number);
  }

  String formatSigned(double amount) {
    final number = _decimalFormat.format(amount.abs());

    return _compose(_isNegative(amount, number) ? '-' : '+', number);
  }

  String formatCompact(double amount) {
    final number = NumberFormat.compactCurrency(
      locale: _numberLocale,
      symbol: '',
      decimalDigits: decimalDigits,
    ).format(amount.abs());

    return _compose(_isNegative(amount, number) ? '-' : '', number);
  }

  bool _isNegative(double amount, String number) {
    return amount < 0 && number.contains(_nonZeroDigit);
  }

  String _compose(String sign, String number) {
    return '$sign$symbol${_applyGrouping(number)}';
  }

  String _applyGrouping(String number) {
    final buffer = StringBuffer();
    for (final unit in number.codeUnits) {
      switch (unit) {
        case _commaUnit:
          buffer.write(grouping.groupSeparator);
        case _dotUnit:
          buffer.write(grouping.decimalSeparator);
        default:
          buffer.writeCharCode(unit);
      }
    }

    return buffer.toString();
  }

  static NumberFormat _decimalFormatFor(int decimalDigits) {
    return NumberFormat.decimalPatternDigits(
      locale: _numberLocale,
      decimalDigits: decimalDigits,
    );
  }
}
