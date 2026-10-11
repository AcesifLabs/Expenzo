import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
}
