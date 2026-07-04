import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class MockGetSettings extends Mock implements GetSettings {}

class MockUpdateSettings extends Mock implements UpdateSettings {}

class _NoParamsFake extends Fake implements NoParams {}

class _UserSettingsFake extends Fake implements UserSettings {}

void main() {
  setUpAll(() {
    registerFallbackValue(_NoParamsFake());
    registerFallbackValue(_UserSettingsFake());
  });
  late MockGetSettings mockGetSettings;
  late MockUpdateSettings mockUpdateSettings;
  late SettingsBloc bloc;

  final testSettings = UserSettings(
    currencySymbol: '\$',
    theme: 'light',
    notificationsEnabled: true,
    emailFetchLimit: 10,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockGetSettings = MockGetSettings();
    mockUpdateSettings = MockUpdateSettings();
    bloc = SettingsBloc(
      getSettings: mockGetSettings,
      updateSettings: mockUpdateSettings,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadSettings', () {
    test('emits [SettingsLoading, SettingsLoaded] on success', () async {
      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Right(testSettings));

      final expected = [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>().having(
          (s) => s.settings.currencySymbol,
          'currencySymbol',
          '\$',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadSettings());
    });

    test('emits [SettingsLoading, SettingsError] on failure', () async {
      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Failed to load')));

      final expected = [
        isA<SettingsLoading>(),
        isA<SettingsError>().having(
          (s) => s.message,
          'message',
          'Failed to load',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadSettings());
    });
  });

  group('UpdateSettingsEvent', () {
    test('emits [SettingsLoading, SettingsLoaded] on success', () async {
      when(
        () => mockUpdateSettings(any()),
      ).thenAnswer((_) async => Right(testSettings));

      final expected = [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>().having((s) => s.settings.theme, 'theme', 'light'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(UpdateSettingsEvent(testSettings));
    });

    test('emits [SettingsLoading, SettingsError] on failure', () async {
      when(
        () => mockUpdateSettings(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Update failed')));

      final expected = [
        isA<SettingsLoading>(),
        isA<SettingsError>().having(
          (s) => s.message,
          'message',
          'Update failed',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(UpdateSettingsEvent(testSettings));
    });
  });
}
