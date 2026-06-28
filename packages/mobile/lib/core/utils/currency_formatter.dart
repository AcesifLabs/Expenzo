import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';

class CurrencyFormatter {
  static String format(double amount, {String? symbol, int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol ?? CurrencyConfig.defaultSymbol,
      decimalDigits: decimalDigits,
    ).format(amount);
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
