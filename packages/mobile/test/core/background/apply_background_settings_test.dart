import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/background/background_dispatcher.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../support/factories/user_settings_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    CurrencyFormatter.current.value = CurrencyConfig.byCode(
      CurrencyConfig.defaultCode,
    );
  });

  test('a saved language and currency are applied', () {
    applyBackgroundSettings(
      makeUserSettings(languageCode: 'bn', currencyCode: 'EUR'),
    );

    expect(LocaleSettings.currentLocale, AppLocale.bn);
    expect(Intl.defaultLocale, AppLocale.bn.languageTag);
    expect(CurrencyFormatter.current.value.code, 'EUR');
  });

  test("'system' follows the device language", () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    applyBackgroundSettings(makeUserSettings(languageCode: 'system'));

    expect(LocaleSettings.currentLocale, AppLocaleUtils.findDeviceLocale());
  });
}
