import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';

/// Formats amounts with a symbol, a fixed number of decimals and the user's
/// digit grouping. What `CurrencyFormatter.getFormatter` returns.
///
/// The number is formatted without the symbol and its marks swapped
/// afterwards, so a symbol containing `.` or `,` is never altered.
class MoneyFormat {
  final String symbol;
  final int decimalDigits;
  final DigitGrouping grouping;

  /// Amounts use Latin digits and English marks before [grouping] applies.
  static const _numberLocale = 'en';
  static const _commaUnit = 0x2C;
  static const _dotUnit = 0x2E;
  static final _nonZeroDigit = RegExp('[1-9]');

  /// Built once and reused, so one MoneyFormat formats a list cheaply.
  final NumberFormat _decimalFormat;

  MoneyFormat({
    required this.symbol,
    required this.decimalDigits,
    required this.grouping,
  }) : _decimalFormat = _decimalFormatFor(decimalDigits);

  /// No symbol: for samples such as the Number format screen's options.
  MoneyFormat.plain({required this.decimalDigits, required this.grouping})
    : symbol = '',
      _decimalFormat = _decimalFormatFor(decimalDigits);

  String format(double amount) {
    final number = _decimalFormat.format(amount.abs());

    return _compose(_isNegative(amount, number) ? '-' : '', number);
  }

  /// Always prefixes a sign: "+৳42.50" / "-৳42.50". An amount that rounds
  /// to zero reads "+".
  String formatSigned(double amount) {
    final number = _decimalFormat.format(amount.abs());

    return _compose(_isNegative(amount, number) ? '-' : '+', number);
  }

  /// "৳1.5K". Compact numbers have no grouping, only a decimal mark.
  String formatCompact(double amount) {
    final number = NumberFormat.compactCurrency(
      locale: _numberLocale,
      symbol: '',
      decimalDigits: decimalDigits,
    ).format(amount.abs());

    return _compose(_isNegative(amount, number) ? '-' : '', number);
  }

  /// Negative only if the shown number isn't zero, so -0.4 at 0 places reads
  /// "৳0", not "-৳0".
  bool _isNegative(double amount, String number) {
    return amount < 0 && number.contains(_nonZeroDigit);
  }

  String _compose(String sign, String number) {
    return '$sign$symbol${_applyGrouping(number)}';
  }

  /// One pass, so dot grouping's ',' ↔ '.' swap doesn't undo itself.
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
