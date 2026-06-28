import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';

/// Shared currency formatting utility.
/// Use this instead of creating NumberFormat.currency instances directly.
class CurrencyFormatter {
  /// Format a number as currency with the given symbol.
  /// Defaults to the app's default currency symbol (৳ BDT).
  static String format(double amount, {String? symbol, int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol ?? CurrencyConfig.defaultSymbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Format a number as compact currency (e.g., $1.2K).
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

  /// Get a NumberFormat instance for currency formatting.
  /// Useful when you need the formatter object for custom formatting.
  static NumberFormat getFormatter({String? symbol, int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol ?? CurrencyConfig.defaultSymbol,
      decimalDigits: decimalDigits,
    );
  }
}
