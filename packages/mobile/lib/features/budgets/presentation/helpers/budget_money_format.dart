import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/money_format.dart';

import 'budget_access_lookup.dart';

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
