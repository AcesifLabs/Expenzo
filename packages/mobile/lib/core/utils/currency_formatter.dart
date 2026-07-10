import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';

class CurrencyFormatter {
  static String format(double amount, {String? symbol, int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol ?? CurrencyConfig.defaultSymbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Formats with explicit sign prefix for positive amounts (+42.50).
  /// Negative amounts get the sign from NumberFormat automatically.
  static String formatSigned(
    double amount, {
    String? symbol,
    int decimalDigits = 2,
  }) {
    final formatted = format(
      amount.abs(),
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    if (amount >= 0) return '+$formatted';
    return '-$formatted';
  }

  static String formatCompact(
    double amount, {
    String? symbol,
    int decimalDigits = 1,
  }) {
    return NumberFormat.compactCurrency(
      symbol: symbol ?? CurrencyConfig.defaultSymbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  static NumberFormat getFormatter({String? symbol, int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol ?? CurrencyConfig.defaultSymbol,
      decimalDigits: decimalDigits,
    );
  }
}
