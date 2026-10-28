import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/money_format.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

abstract final class CurrencyFormatter {
  static final ValueNotifier<CurrencyInfo> current = ValueNotifier(
    CurrencyConfig.byCode(CurrencyConfig.defaultCode),
  );

  static final ValueNotifier<NumberDisplayFormat> displayFormat = ValueNotifier(
    NumberDisplayFormat.standard,
  );

  static const _numberLocale = 'en';

  static const _storedDecimalDigits = 2;

  static String get decimalSeparator =>
      displayFormat.value.grouping.decimalSeparator;

  static MoneyFormat getFormatter({int? decimalDigits}) =>
      _formatterFor(current.value, decimalDigits);

  static MoneyFormat getFormatterFor(
    String currencyCode, {
    int? decimalDigits,
  }) => _formatterFor(CurrencyConfig.byCode(currencyCode), decimalDigits);

  static String formatIn(
    double amount,
    String currencyCode, {
    int? decimalDigits,
  }) => getFormatterFor(
    currencyCode,
    decimalDigits: decimalDigits,
  ).format(amount);

  static String format(double amount, {int? decimalDigits}) {
    return getFormatter(decimalDigits: decimalDigits).format(amount);
  }

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

  static String formatSigned(double amount, {int? decimalDigits}) {
    return getFormatter(decimalDigits: decimalDigits).formatSigned(amount);
  }

  static String formatCompact(double amount, {int? decimalDigits = 1}) {
    return getFormatter(decimalDigits: decimalDigits).formatCompact(amount);
  }

  static String formatInput(double amount) {
    final fixed = amount.toStringAsFixed(
      max(current.value.decimalDigits, _storedDecimalDigits),
    );
    if (!fixed.contains('.')) return fixed;

    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static MoneyFormat _formatterFor(CurrencyInfo currency, int? decimalDigits) {
    return MoneyFormat(
      symbol: currency.symbol,
      decimalDigits: _digits(currency, decimalDigits),
      grouping: displayFormat.value.grouping,
    );
  }

  static int _digits(CurrencyInfo currency, int? requested) {
    return min(
      min(requested ?? currency.decimalDigits, currency.decimalDigits),
      displayFormat.value.decimalPlaces,
    );
  }
}
