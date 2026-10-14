import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/background/background_dispatcher.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../support/factories/user_settings_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    CurrencyFormatter.current.value = CurrencyConfig.byCode(
      CurrencyConfig.defaultCode,
    );
    CurrencyFormatter.displayFormat.value = NumberDisplayFormat.standard;
    WeekStart.current.value = FirstDayOfWeek.monday;
  });

  test('a saved number format is applied', () {
    applyBackgroundSettings(
      makeUserSettings(decimalPlaces: 0, digitGrouping: DigitGrouping.dot),
    );

    expect(
      CurrencyFormatter.displayFormat.value,
      const NumberDisplayFormat(decimalPlaces: 0, grouping: DigitGrouping.dot),
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

  test('an unset first day of week follows the Bangla default', () {
    applyBackgroundSettings(makeUserSettings(languageCode: 'bn'));

    expect(WeekStart.current.value, FirstDayOfWeek.saturday);
  });

  test('a stored first day of week is applied', () {
    applyBackgroundSettings(
      makeUserSettings(
        languageCode: 'bn',
        firstDayOfWeek: FirstDayOfWeek.sunday,
      ),
    );

    expect(WeekStart.current.value, FirstDayOfWeek.sunday);
  });
}
