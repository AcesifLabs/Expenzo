import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/money_format.dart';

import 'budget_access_lookup.dart';

// Null keeps the currency's own decimals.
// ignore: unnecessary-nullable
/// [fallback] for a personal budget; the Family Group's Currency for one
/// shared into [groupId] (CONTEXT.md Shared Budget).
MoneyFormat budgetMoneyFormat(
  String? groupId, {
  required MoneyFormat fallback,
  int? decimalDigits,
}) {
  final currencyCode = budgetAccess().currencyFor(groupId);

  return currencyCode == null
      ? fallback
      : CurrencyFormatter.getFormatterFor(
          currencyCode,
          decimalDigits: decimalDigits,
        );
}
