import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Currencies whose code, symbol, English name or name in the app
/// language contains [query], in [CurrencyConfig.supported] order.
List<CurrencyInfo> searchCurrencies(
  String query, {
  List<CurrencyInfo> currencies = CurrencyConfig.supported,
}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return currencies;
  // Read once: slang builds a new map on every `names` access. Same lookup
  // as CurrencyInfo.displayName.
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
