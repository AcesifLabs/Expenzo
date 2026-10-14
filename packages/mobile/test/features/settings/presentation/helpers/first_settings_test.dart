import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/settings/presentation/helpers/first_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

import '../../../../support/factories/user_settings_factory.dart';

void main() {
  late StreamController<SettingsState> states;

  setUp(() => states = StreamController<SettingsState>.broadcast());
  tearDown(() => states.close());

  test('a load gives the loaded settings', () async {
    final settings = makeUserSettings();
    final result = firstSettings(states.stream);
    states
      ..add(const SettingsLoading())
      ..add(SettingsLoaded(settings));

    expect(await result, settings);
  });

  test('a load error gives null', () async {
    final result = firstSettings(states.stream);
    states.add(const SettingsError('boom'));

    expect(await result, isNull);
  });

  test('nothing within the timeout gives null', () async {
    final result = firstSettings(
      states.stream,
      timeout: const Duration(milliseconds: 10),
    );
    states.add(const SettingsLoading());

    expect(await result, isNull);
  });

  test('a closed stream gives null', () async {
    final result = firstSettings(states.stream);
    await states.close();

    expect(await result, isNull);
  });
}
