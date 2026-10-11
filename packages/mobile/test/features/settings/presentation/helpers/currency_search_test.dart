import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/features/settings/presentation/helpers/currency_search.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

void main() {
  List<String> codes(String query) =>
      searchCurrencies(query).map((c) => c.code).toList();

  setUp(() => LocaleSettings.setLocaleSync(AppLocale.en));
  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('an empty or blank query returns every supported currency', () {
    expect(searchCurrencies(''), CurrencyConfig.supported);
    expect(searchCurrencies('   '), CurrencyConfig.supported);
    expect(CurrencyConfig.supported, hasLength(28));
  });

  test('the code matches case-insensitively', () {
    expect(codes('bdt'), ['BDT']);
    expect(codes('USD'), contains('USD'));
  });

  test('the English name matches, keeping the supported order', () {
    expect(codes('rupee'), ['INR', 'PKR', 'NPR', 'LKR']);
    expect(codes('dollar'), contains('USD'));
    expect(codes('dollar').length, greaterThan(1));
  });

  test('the symbol matches', () {
    expect(codes('৳'), ['BDT']);
    expect(codes(r'$'), contains('USD'));
  });

  test('the name in the app language matches', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    expect(codes('ভারতীয়'), ['INR']);
  });

  test('a query with no match returns nothing', () {
    expect(codes('zzz'), isEmpty);
  });
}
