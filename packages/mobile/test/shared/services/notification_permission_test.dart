import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_permission.dart';

import '../../support/factories/user_settings_factory.dart';

class _MockGetSettings extends Mock implements GetSettings {}

const _channel = MethodChannel('flutter.baseflow.com/permissions/methods');
const _notification = 17;
const _denied = 0;
const _granted = 1;
const _permanentlyDenied = 4;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockGetSettings getSettings;
  late List<String> calls;

  setUpAll(() => registerFallbackValue(NoParams()));

  void answerStatus(int status) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call.method);

          return switch (call.method) {
            'checkPermissionStatus' => status,
            'requestPermissions' => {_notification: _granted},
            _ => null,
          };
        });
  }

  setUp(() {
    calls = [];
    getSettings = _MockGetSettings();
    di.getIt.registerSingleton<GetSettings>(getSettings);
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(makeUserSettings()));
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    await di.getIt.reset();
  });

  test(
    'asks when auto-import notifications are on and never answered',
    () async {
      answerStatus(_denied);

      await requestAutoImportPermissionIfNeeded();

      expect(calls, ['checkPermissionStatus', 'requestPermissions']);
    },
  );

  test('does not ask once permission is granted', () async {
    answerStatus(_granted);

    await requestAutoImportPermissionIfNeeded();

    expect(calls, ['checkPermissionStatus']);
  });

  test('does not ask once permission is permanently denied', () async {
    answerStatus(_permanentlyDenied);

    await requestAutoImportPermissionIfNeeded();

    expect(calls, ['checkPermissionStatus']);
  });

  test('does not ask when the auto-import switch is off', () async {
    answerStatus(_denied);
    when(() => getSettings(any())).thenAnswer(
      (_) async => Right(makeUserSettings(autoImportAlertsEnabled: false)),
    );

    await requestAutoImportPermissionIfNeeded();

    expect(calls, isEmpty);
  });

  test('does not ask when the master switch is off', () async {
    answerStatus(_denied);
    when(() => getSettings(any())).thenAnswer(
      (_) async => Right(makeUserSettings(notificationsEnabled: false)),
    );

    await requestAutoImportPermissionIfNeeded();

    expect(calls, isEmpty);
  });

  test('does not ask when settings fail to load', () async {
    answerStatus(_denied);
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'no settings')));

    await requestAutoImportPermissionIfNeeded();

    expect(calls, isEmpty);
  });

  test('swallows errors when settings are not registered yet', () async {
    answerStatus(_denied);
    await di.getIt.reset();

    await expectLater(requestAutoImportPermissionIfNeeded(), completes);
    expect(calls, isEmpty);
  });
}
