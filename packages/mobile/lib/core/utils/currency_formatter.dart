import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/money_format.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Formats every amount in the app from the user's currency (docs/adr/0002).
///
/// [current] is updated by `ExpenzoApp` whenever Settings load or change.
abstract final class CurrencyFormatter {
  static final ValueNotifier<CurrencyInfo> current = ValueNotifier(
    CurrencyConfig.byCode(CurrencyConfig.defaultCode),
  );

  /// Updated by `ExpenzoApp` from Settings (SAAP-65). Display only: amounts
  /// are stored and summed with full precision and rounded here.
  static final ValueNotifier<NumberDisplayFormat> displayFormat = ValueNotifier(
    NumberDisplayFormat.standard,
  );

  /// Amounts use Latin digits and Western grouping in every app language.
  static const _numberLocale = 'en';

  /// Amounts are stored with up to two decimals, whatever the currency.
  static const _storedDecimalDigits = 2;

  /// The decimal mark amounts show; typed amounts are still stored with '.'.
  static String get decimalSeparator =>
      displayFormat.value.grouping.decimalSeparator;

  /// [decimalDigits] can only lower the currency's own precision (a summary
  /// may drop decimals; yen never gains them), and so can the user's
  /// decimal places setting.
  static MoneyFormat getFormatter({int? decimalDigits}) {
    final currency = current.value;

    return MoneyFormat(
      symbol: currency.symbol,
      decimalDigits: _digits(currency, decimalDigits),
      grouping: displayFormat.value.grouping,
    );
  }

  static String format(double amount, {int? decimalDigits}) {
    return getFormatter(decimalDigits: decimalDigits).format(amount);
  }

  /// What a screen reader says for a money amount, since "−" and a currency
  /// symbol are often skipped: "Expense, 122.50 Bangladeshi taka".
  ///
  /// Keeps English marks whatever the digit grouping: screen readers read
  /// "1,234.56" correctly but may misread "1.234,56". Decimal places apply.
  static String semanticsLabel(double amount, {required bool isExpense}) {
    final currency = current.value;
    final number = NumberFormat.decimalPatternDigits(
      locale: _numberLocale,
      decimalDigits: _digits(currency, null),
    ).format(amount.abs());

    final a11y = t.common.a11y;

    return isExpense
        ? a11y.expenseAmount(amount: number, currency: currency.displayName)
        : a11y.incomeAmount(amount: number, currency: currency.displayName);
  }

  /// Always prefixes a sign: "+৳42.50" / "-৳42.50".
  static String formatSigned(double amount, {int? decimalDigits}) {
    return getFormatter(decimalDigits: decimalDigits).formatSigned(amount);
  }

  static String formatCompact(double amount, {int? decimalDigits = 1}) {
    return getFormatter(decimalDigits: decimalDigits).formatCompact(amount);
  }

  /// A plain number for editable amount fields: no symbol, no grouping,
  /// no trailing zeros (122 → "122", 122.5 → "122.5").
  ///
  /// Never rounds below cents: the field is saved back as typed, so an edit
  /// prefill must not change the stored amount (12.50 stays "12.5" even in
  /// yen).
  ///
  /// Ignores the Number format setting: always a '.' decimal and no
  /// grouping, because callers read it back with `double.tryParse`.
  static String formatInput(double amount) {
    final fixed = amount.toStringAsFixed(
      max(current.value.decimalDigits, _storedDecimalDigits),
    );
    if (!fixed.contains('.')) return fixed;

    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static int _digits(CurrencyInfo currency, int? requested) {
    return min(
      min(requested ?? currency.decimalDigits, currency.decimalDigits),
      displayFormat.value.decimalPlaces,
    );
  }
}
