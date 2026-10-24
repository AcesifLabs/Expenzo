import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/resolve_onboarding_status.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockUpdateSettings extends Mock implements UpdateSettings {}

class _MockLocal extends Mock implements OnboardingLocalDatasource {}

void main() {
  late _MockGetSettings getSettings;
  late _MockUpdateSettings updateSettings;
  late _MockLocal local;
  late ResolveOnboardingStatus resolve;

  UserSettings settings({bool? onboardingCompleted}) => UserSettings(
    currencyCode: 'BDT',
    emailFetchLimit: 100,
    notificationsEnabled: true,
    theme: 'system',
    onboardingCompleted: onboardingCompleted,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(settings());
  });

  setUp(() {
    getSettings = _MockGetSettings();
    updateSettings = _MockUpdateSettings();
    local = _MockLocal();
    resolve = ResolveOnboardingStatus(
      getSettings: getSettings,
      updateSettings: updateSettings,
      local: local,
    );
    when(() => updateSettings(any())).thenAnswer(
      (i) async => Right(i.positionalArguments.first as UserSettings),
    );
  });

  void stored(bool? flag) => when(
    () => getSettings(any()),
  ).thenAnswer((_) async => Right(settings(onboardingCompleted: flag)));

  test('a known flag is returned as-is with no write', () async {
    stored(false);

    expect(await resolve(), const Right<Object, bool>(false));
    verifyNever(() => updateSettings(any()));
    verifyNever(() => local.hasUserData());
  });

  test('no flag and existing data marks onboarding done', () async {
    stored(null);
    when(() => local.hasUserData()).thenAnswer((_) async => true);

    expect(await resolve(), const Right<Object, bool>(true));
    final saved =
        verify(() => updateSettings(captureAny())).captured.single
            as UserSettings;
    expect(saved.onboardingCompleted, isTrue);
  });

  test('no flag and no data leaves onboarding to do', () async {
    stored(null);
    when(() => local.hasUserData()).thenAnswer((_) async => false);

    expect(await resolve(), const Right<Object, bool>(false));
    final saved =
        verify(() => updateSettings(captureAny())).captured.single
            as UserSettings;
    expect(saved.onboardingCompleted, isFalse);
  });
}
