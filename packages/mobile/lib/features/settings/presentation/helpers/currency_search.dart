import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

List<CurrencyInfo> searchCurrencies(
  String query, {
  List<CurrencyInfo> currencies = CurrencyConfig.supported,
}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return currencies;

  final names = t.currencies.names;

  return [
    for (final currency in currencies)
      if ([
        currency.code,
        currency.symbol.trim(),
        currency.name,
        names[currency.code] ?? currency.name,
      ].any((field) => field.toLowerCase().contains(needle)))
        currency,
  ];
}
