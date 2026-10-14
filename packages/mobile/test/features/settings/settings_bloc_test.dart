import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/delete_account.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class MockGetSettings extends Mock implements GetSettings {}

class MockUpdateSettings extends Mock implements UpdateSettings {}

class MockDeleteAccount extends Mock implements DeleteAccount {}

class _NoParamsFake extends Fake implements NoParams {}

class _UserSettingsFake extends Fake implements UserSettings {}

void main() {
  setUpAll(() {
    registerFallbackValue(_NoParamsFake());
    registerFallbackValue(_UserSettingsFake());
  });
  late MockGetSettings mockGetSettings;
  late MockUpdateSettings mockUpdateSettings;
  late MockDeleteAccount mockDeleteAccount;
  late SettingsBloc bloc;

  final testSettings = UserSettings(
    currencyCode: 'USD',
    theme: 'light',
    notificationsEnabled: true,
    emailFetchLimit: 10,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockGetSettings = MockGetSettings();
    mockUpdateSettings = MockUpdateSettings();
    mockDeleteAccount = MockDeleteAccount();
    bloc = SettingsBloc(
      getSettings: mockGetSettings,
      updateSettings: mockUpdateSettings,
      deleteAccount: mockDeleteAccount,
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
          (s) => s.settings.currencyCode,
          'currencyCode',
          'USD',
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
          t.common.errors.server,
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

    test(
      'on failure emits SettingsError, then reloads the stored settings',
      () async {
        when(
          () => mockGetSettings(any()),
        ).thenAnswer((_) async => Right(testSettings));
        when(() => mockUpdateSettings(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Update failed')),
        );

        final expected = [
          isA<SettingsLoading>(),
          isA<SettingsError>().having(
            (s) => s.message,
            'message',
            t.common.errors.server,
          ),
          isA<SettingsLoading>(),
          isA<SettingsLoaded>().having(
            (s) => s.settings,
            'settings',
            testSettings,
          ),
        ];

        final emitted = expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(UpdateSettingsEvent(testSettings.copyWith(theme: 'dark')));
        await emitted;
      },
    );

    test('a change after a failed save is still saved', () async {
      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Right(testSettings));
      when(
        () => mockUpdateSettings(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Update failed')));
      bloc.add(UpdateSettingsEvent(testSettings.copyWith(theme: 'dark')));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      when(() => mockUpdateSettings(any())).thenAnswer(
        (i) async => Right(i.positionalArguments.first as UserSettings),
      );
      bloc.add(const UpdateTheme('dark'));
      final loaded = await bloc.stream.firstWhere(
        (s) => s is SettingsLoaded && s.settings.theme == 'dark',
      );

      expect((loaded as SettingsLoaded).settings.theme, 'dark');
    });

    test('a change after a failed save and a failed reload does not '
        're-save the failed value', () async {
      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Right(testSettings));
      when(() => mockUpdateSettings(any())).thenAnswer(
        (i) async => Right(i.positionalArguments.first as UserSettings),
      );
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'read failed')));
      when(
        () => mockUpdateSettings(any()),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'write failed')));
      bloc.add(const UpdateTheme('dark'));
      await bloc.stream.firstWhere((s) => s is SettingsError);
      await bloc.stream.firstWhere((s) => s is SettingsError);
      clearInteractions(mockUpdateSettings);

      bloc.add(const UpdateLanguage('bn'));
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockUpdateSettings(any()));
    });
  });

  group('DeleteAccountEvent', () {
    test('emits [SettingsLoading, AccountDeleted] on success', () async {
      when(() => mockDeleteAccount(any())).thenAnswer((_) async => Right(unit));

      final expected = [isA<SettingsLoading>(), isA<AccountDeleted>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const DeleteAccountEvent());
    });

    test('emits [SettingsLoading, SettingsError] on failure', () async {
      when(
        () => mockDeleteAccount(any()),
      ).thenAnswer((_) async => Left(AuthFailure(message: 'Delete failed')));

      final expected = [
        isA<SettingsLoading>(),
        isA<SettingsError>().having(
          (s) => s.message,
          'message',
          t.common.errors.auth,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const DeleteAccountEvent());
    });
  });

  group('derived updates', () {
    Future<UserSettings> savedAfter(SettingsEvent event) async {
      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Right(testSettings));
      when(() => mockUpdateSettings(any())).thenAnswer(
        (i) async => Right(i.positionalArguments.first as UserSettings),
      );
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(event);
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      return verify(() => mockUpdateSettings(captureAny())).captured.single
          as UserSettings;
    }

    test(
      'UpdateCurrency saves the ISO code and keeps other settings',
      () async {
        final saved = await savedAfter(const UpdateCurrency('BDT'));

        expect(saved.currencyCode, 'BDT');
        expect(saved.theme, 'light');
        expect(saved.notificationsEnabled, isTrue);
      },
    );

    test('UpdateLanguage saves the code and keeps other settings', () async {
      final saved = await savedAfter(const UpdateLanguage('bn'));

      expect(saved.languageCode, 'bn');
      expect(saved.theme, 'light');
    });

    test('DismissAutoImportPrompt saves the dismissal', () async {
      final saved = await savedAfter(const DismissAutoImportPrompt());

      expect(saved.autoImportPromptDismissed, isTrue);
      expect(saved.currencyCode, 'USD');
    });

    test('UpdateDefaultRecurringFrequency saves the frequency and keeps other '
        'settings', () async {
      final saved = await savedAfter(
        const UpdateDefaultRecurringFrequency('yearly'),
      );

      expect(saved.defaultRecurringFrequency, 'yearly');
      expect(saved.theme, 'light');
      expect(saved.recurringAutoCreate, isFalse);
    });

    test(
      'UpdateRecurringAutoCreate saves the switch and keeps other settings',
      () async {
        final saved = await savedAfter(const UpdateRecurringAutoCreate(true));

        expect(saved.recurringAutoCreate, isTrue);
        expect(saved.theme, 'light');
        expect(saved.defaultRecurringFrequency, 'monthly');
      },
    );

    test(
      'UpdateNumberFormat ignores decimal places outside the choices',
      () async {
        when(
          () => mockGetSettings(any()),
        ).thenAnswer((_) async => Right(testSettings));
        bloc.add(const LoadSettings());
        await bloc.stream.firstWhere((s) => s is SettingsLoaded);

        bloc.add(const UpdateNumberFormat(decimalPlaces: 3));
        await pumpEventQueue();

        verifyNever(() => mockUpdateSettings(any()));
        expect(bloc.latestSettings, testSettings);
      },
    );

    test('UpdateFontSize saves only the font size', () async {
      final saved = await savedAfter(const UpdateFontSize(AppFontSize.large));

      expect(saved, testSettings.copyWith(fontSize: AppFontSize.large));
    });

    test('UpdateNumberFormat changes only the given field', () async {
      final saved = await savedAfter(
        const UpdateNumberFormat(digitGrouping: DigitGrouping.dot),
      );

      expect(saved, testSettings.copyWith(digitGrouping: DigitGrouping.dot));
    });

    test('UpdateNotificationToggle saves only its own toggle', () async {
      final saved = await savedAfter(
        const UpdateNotificationToggle(NotificationToggle.weeklySummary, true),
      );

      expect(saved.weeklySummaryEnabled, isTrue);
      expect(saved, testSettings.copyWith(weeklySummaryEnabled: true));
    });

    test('a change made while a save runs keeps both changes', () async {
      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Right(testSettings));
      when(() => mockUpdateSettings(any())).thenAnswer(
        (i) async => Right(i.positionalArguments.first as UserSettings),
      );
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc
        ..add(const UpdateTheme('dark'))
        ..add(const UpdateLanguage('bn'));
      await bloc.stream.firstWhere(
        (s) => s is SettingsLoaded && s.settings.languageCode == 'bn',
      );

      final saved = verify(
        () => mockUpdateSettings(captureAny()),
      ).captured.cast<UserSettings>();
      expect(saved, hasLength(2));
      expect(saved.last.theme, 'dark');
      expect(saved.last.languageCode, 'bn');
    });

    test('latestSettings has a change before its save finishes', () async {
      when(
        () => mockGetSettings(any()),
      ).thenAnswer((_) async => Right(testSettings));
      final saved = Completer<Either<Failure, UserSettings>>();
      when(() => mockUpdateSettings(any())).thenAnswer((_) => saved.future);
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateDefaultRecurringFrequency('yearly'));
      await bloc.stream.firstWhere((s) => s is SettingsLoading);

      expect(bloc.latestSettings?.defaultRecurringFrequency, 'yearly');
      saved.complete(
        Right(testSettings.copyWith(defaultRecurringFrequency: 'yearly')),
      );
    });

    test('derived updates do nothing before settings have loaded', () async {
      bloc
        ..add(const UpdateCurrency('BDT'))
        ..add(const DismissAutoImportPrompt())
        ..add(const UpdateDefaultRecurringFrequency('weekly'))
        ..add(const UpdateRecurringAutoCreate(true))
        ..add(
          const UpdateNotificationToggle(NotificationToggle.budgetOver, false),
        );
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockUpdateSettings(any()));
    });
  });
}
