import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_local_datasource.dart';

Map<String, Object?> _storedSettings({String? currencySymbol, String? code}) {
  return {
    'id': 1,
    'currencySymbol': ?currencySymbol,
    'currencyCode': ?code,
    'emailFetchLimit': 100,
    'notificationsEnabled': true,
    'theme': 'system',
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
  };
}

void main() {
  Future<SettingsLocalDatasourceImpl> datasourceWith(
    Map<String, Object?>? stored,
  ) async {
    SharedPreferences.setMockInitialValues({
      if (stored != null) 'user_settings': jsonEncode(stored),
    });

    return SettingsLocalDatasourceImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  }

  test('a first run defaults to BDT', () async {
    final datasource = await datasourceWith(null);

    expect((await datasource.getSettings()).currencyCode, 'BDT');
  });

  test('a stored ISO code is read as-is', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'EUR'));

    expect((await datasource.getSettings()).currencyCode, 'EUR');
  });

  test('a legacy dollar symbol migrates to USD', () async {
    final datasource = await datasourceWith(
      _storedSettings(currencySymbol: '\$'),
    );

    expect((await datasource.getSettings()).currencyCode, 'USD');
  });

  test('an unknown legacy symbol falls back to BDT', () async {
    final datasource = await datasourceWith(
      _storedSettings(currencySymbol: 'xx'),
    );

    expect((await datasource.getSettings()).currencyCode, 'BDT');
  });

  test('saving writes the code, not the old symbol', () async {
    final datasource = await datasourceWith(
      _storedSettings(currencySymbol: '€'),
    );
    final settings = await datasource.getSettings();
    await datasource.updateSettings(settings);

    final prefs = await SharedPreferences.getInstance();
    final saved =
        jsonDecode(prefs.getString('user_settings') ?? '{}')
            as Map<String, dynamic>;
    expect(saved['currencyCode'], 'EUR');
    expect(saved.containsKey('currencySymbol'), isFalse);
  });

  test('settings saved before languages existed follow the device', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));

    expect((await datasource.getSettings()).languageCode, 'system');
  });

  test('the language is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();
    await datasource.updateSettings(settings.copyWith(languageCode: 'bn'));

    expect((await datasource.getSettings()).languageCode, 'bn');
  });

  test('the auto-import prompt flag defaults to false and is saved', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();
    expect(settings.autoImportPromptDismissed, isFalse);

    await datasource.updateSettings(
      settings.copyWith(autoImportPromptDismissed: true),
    );

    expect((await datasource.getSettings()).autoImportPromptDismissed, isTrue);
  });

  test('settings saved before recurring defaults existed load monthly and '
      'auto-create off', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();

    expect(settings.defaultRecurringFrequency, 'monthly');
    expect(settings.recurringAutoCreate, isFalse);
  });

  test('the default recurring frequency is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();
    await datasource.updateSettings(
      settings.copyWith(defaultRecurringFrequency: 'weekly'),
    );

    expect(
      (await datasource.getSettings()).defaultRecurringFrequency,
      'weekly',
    );
  });

  test('recurring auto-create is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();
    await datasource.updateSettings(
      settings.copyWith(recurringAutoCreate: true),
    );

    expect((await datasource.getSettings()).recurringAutoCreate, isTrue);
  });

  test('settings saved before notification toggles existed load weekly off '
      'and the other three on', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();

    expect(settings.budgetOverAlertsEnabled, isTrue);
    expect(settings.budgetNearLimitAlertsEnabled, isTrue);
    expect(settings.weeklySummaryEnabled, isFalse);
    expect(settings.recurringRemindersEnabled, isTrue);
  });

  test('each notification toggle is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();
    await datasource.updateSettings(
      settings.copyWith(
        budgetOverAlertsEnabled: false,
        budgetNearLimitAlertsEnabled: false,
        weeklySummaryEnabled: true,
        recurringRemindersEnabled: false,
      ),
    );
    final reloaded = await datasource.getSettings();

    expect(reloaded.budgetOverAlertsEnabled, isFalse);
    expect(reloaded.budgetNearLimitAlertsEnabled, isFalse);
    expect(reloaded.weeklySummaryEnabled, isTrue);
    expect(reloaded.recurringRemindersEnabled, isFalse);
  });

  test('settings saved before number format existed load 2 places and '
      'comma grouping', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();

    expect(settings.decimalPlaces, 2);
    expect(settings.digitGrouping, DigitGrouping.comma);
  });

  test('the number format is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();
    await datasource.updateSettings(
      settings.copyWith(decimalPlaces: 0, digitGrouping: DigitGrouping.space),
    );

    final reloaded = await datasource.getSettings();
    expect(reloaded.decimalPlaces, 0);
    expect(reloaded.digitGrouping, DigitGrouping.space);
  });

  test(
    'invalid stored number format values fall back to the defaults',
    () async {
      final datasource = await datasourceWith({
        ..._storedSettings(code: 'BDT'),
        'decimalPlaces': 3,
        'digitGrouping': 'apostrophe',
      });
      final settings = await datasource.getSettings();

      expect(settings.decimalPlaces, 2);
      expect(settings.digitGrouping, DigitGrouping.comma);
    },
  );

  test('settings saved before font size existed load medium', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));

    expect((await datasource.getSettings()).fontSize, AppFontSize.medium);
  });

  test('an unknown stored font size loads medium', () async {
    final datasource = await datasourceWith({
      ..._storedSettings(code: 'BDT'),
      'fontSize': 'huge',
    });

    expect((await datasource.getSettings()).fontSize, AppFontSize.medium);
  });

  test('each font size is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();

    for (final size in AppFontSize.values) {
      await datasource.updateSettings(settings.copyWith(fontSize: size));
      expect((await datasource.getSettings()).fontSize, size);
    }
  });

  test('settings saved before first day of week existed load unset', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));

    expect((await datasource.getSettings()).firstDayOfWeek, isNull);
  });

  test('an unknown stored first day of week loads unset', () async {
    final datasource = await datasourceWith({
      ..._storedSettings(code: 'BDT'),
      'firstDayOfWeek': 'friday',
    });

    expect((await datasource.getSettings()).firstDayOfWeek, isNull);
  });

  test('each first day of week is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();

    for (final day in FirstDayOfWeek.values) {
      await datasource.updateSettings(settings.copyWith(firstDayOfWeek: day));
      expect((await datasource.getSettings()).firstDayOfWeek, day);
    }
  });

  test('settings saved before the home tab existed open on home', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));

    expect((await datasource.getSettings()).homeTab, AppRootTab.home);
  });

  test('an unknown stored home tab opens on home', () async {
    final datasource = await datasourceWith({
      ..._storedSettings(code: 'BDT'),
      'homeTab': 'scan',
    });

    expect((await datasource.getSettings()).homeTab, AppRootTab.home);
  });

  test('each home tab is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();

    for (final tab in AppRootTab.values) {
      await datasource.updateSettings(settings.copyWith(homeTab: tab));
      expect((await datasource.getSettings()).homeTab, tab);
    }
  });

  test('reset replaces customised settings with the defaults', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'USD'));
    final custom = await datasource.getSettings();
    await datasource.updateSettings(
      custom.copyWith(
        theme: 'dark',
        languageCode: 'bn',
        fontSize: AppFontSize.large,
        digitGrouping: DigitGrouping.space,
        firstDayOfWeek: FirstDayOfWeek.saturday,
        homeTab: AppRootTab.reports,
      ),
    );

    final reset = await datasource.resetSettings();

    expect(reset.currencyCode, 'BDT');
    expect(reset.theme, 'system');
    expect(reset.languageCode, 'system');
    expect(reset.fontSize, AppFontSize.defaultSize);
    expect(reset.firstDayOfWeek, isNull);
    expect(reset.homeTab, AppRootTab.home);
    expect(reset.createdAt.isAfter(custom.createdAt), isTrue);
    expect(await datasource.getSettings(), reset);
  });

  test('settings saved before the sync switch existed have sync on', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));

    expect((await datasource.getSettings()).syncEnabled, isTrue);
  });

  test('the sync switch is saved and read back', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();

    await datasource.updateSettings(settings.copyWith(syncEnabled: false));

    expect((await datasource.getSettings()).syncEnabled, isFalse);
  });

  test('a reset turns sync back on', () async {
    final datasource = await datasourceWith(_storedSettings(code: 'BDT'));
    final settings = await datasource.getSettings();
    await datasource.updateSettings(settings.copyWith(syncEnabled: false));

    expect((await datasource.resetSettings()).syncEnabled, isTrue);
  });
}
