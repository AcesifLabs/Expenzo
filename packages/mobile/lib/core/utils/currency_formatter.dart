import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Formats every amount in the app from the user's currency (docs/adr/0002).
///
/// [current] is updated by `ExpenzoApp` whenever Settings load or change.
abstract final class CurrencyFormatter {
  static final ValueNotifier<CurrencyInfo> current = ValueNotifier(
    CurrencyConfig.byCode(CurrencyConfig.defaultCode),
  );

  /// Amounts use Latin digits and Western grouping in every app language.
  static const _numberLocale = 'en';

  /// [decimalDigits] can only lower the currency's own precision (a summary
  /// may drop decimals; yen never gains them).
  static NumberFormat getFormatter({int? decimalDigits}) {
    final currency = current.value;

    return NumberFormat.currency(
      locale: _numberLocale,
      symbol: currency.symbol,
      decimalDigits: _digits(currency, decimalDigits),
    );
  }

  static String format(double amount, {int? decimalDigits}) {
    return getFormatter(decimalDigits: decimalDigits).format(amount);
  }

  /// What a screen reader says for a money amount, since "−" and a currency
  /// symbol are often skipped: "Expense, 122.50 Bangladeshi taka".
  static String semanticsLabel(double amount, {required bool isExpense}) {
    final currency = current.value;
    final number = NumberFormat.decimalPatternDigits(
      locale: _numberLocale,
      decimalDigits: currency.decimalDigits,
    ).format(amount.abs());

    return isExpense
        ? t.common.a11y.expenseAmount(
            amount: number,
            currency: currency.displayName,
          )
        : t.common.a11y.incomeAmount(
            amount: number,
            currency: currency.displayName,
          );
  }

  /// Always prefixes a sign: "+৳42.50" / "-৳42.50".
  static String formatSigned(double amount, {int? decimalDigits}) {
    final formatted = format(amount.abs(), decimalDigits: decimalDigits);

    return amount < 0 ? '-$formatted' : '+$formatted';
  }

  static String formatCompact(double amount, {int? decimalDigits = 1}) {
    final currency = current.value;

    return NumberFormat.compactCurrency(
      locale: _numberLocale,
      symbol: currency.symbol,
      decimalDigits: _digits(currency, decimalDigits),
    ).format(amount);
  }

  /// A plain number for editable amount fields: no symbol, no grouping,
  /// no trailing zeros (122 → "122", 122.5 → "122.5").
  ///
  /// Never rounds below cents: the field is saved back as typed, so an edit
  /// prefill must not change the stored amount (12.50 stays "12.5" even in
  /// yen).
  static String formatInput(double amount) {
    final fixed = amount.toStringAsFixed(
      max(current.value.decimalDigits, _storedDecimalDigits),
    );
    if (!fixed.contains('.')) return fixed;

    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// Amounts are stored with up to two decimals, whatever the currency.
  static const _storedDecimalDigits = 2;

  static int _digits(CurrencyInfo currency, int? requested) {
    if (requested == null) return currency.decimalDigits;

    return min(requested, currency.decimalDigits);
  }
}
