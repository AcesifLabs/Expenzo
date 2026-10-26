import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';

import 'data_wipe_test_harness.dart';

void main() {
  late DataWipeHarness harness;

  setUp(() async {
    harness = DataWipeHarness();
    await harness.setUp();
  });

  tearDown(() => harness.db.close());

  Future<Failure?> failureOf() async =>
      (await harness.repository.deleteAllData()).fold((f) => f, (_) => null);

  test(
    'signed out never calls the server, wipes local data and lifts the pause',
    () async {
      expect(
        await harness.repository.deleteAllData(),
        const Right<Failure, Unit>(unit),
      );

      verifyNever(() => harness.remote.clearSyncedData());
      expect(await harness.recordCount(), 0);
      expect(harness.calls.first, 'pauseSync');

      expect(harness.calls.last, 'resumeSync');
      expect(harness.calls, isNot(contains('resetSyncState')));
    },
  );

  test('a server failure leaves local data intact and restarts sync', () async {
    harness.signedIn = true;
    harness.serverFails(const ServerException(message: '500'));

    expect(await failureOf(), isA<ServerFailure>());
    expect(await harness.recordCount(), 2);
    expect(harness.prefs.getString('user_settings'), contains('"USD"'));
    expect(harness.prefs.getBool('budget_names_repaired_u1'), isTrue);
    expect(harness.calls, ['pauseSync', 'resumeSync']);
  });

  test('offline and auth failures keep their type', () async {
    harness.signedIn = true;
    harness.serverFails(const NetworkException(message: 'offline'));
    expect(await failureOf(), isA<NetworkFailure>());

    harness.serverFails(const AuthException(message: '401'));
    expect(await failureOf(), isA<AuthFailure>());
  });

  test('a failed wipe after the server was cleared resets sync state, so '
      'the next start pushes the device data back', () async {
    harness.signedIn = true;
    harness.serverClears();
    harness.wipeFails = true;

    expect(await failureOf(), isA<CacheFailure>());
    expect(harness.calls, [
      'pauseSync',
      'clearServer',
      'wipe',
      'resetSyncState',
      'resumeSync',
    ]);
  });

  test(
    'an unexpected error becomes a failure and sync still restarts',
    () async {
      harness.signedIn = true;
      harness.serverClears();
      harness.resetSyncError = StateError('secure storage');

      expect(
        await harness.repository.deleteAllData(),
        const Right<Failure, Unit>(unit),
      );
      expect(harness.calls.last, 'resumeSync');

      when(() => harness.remote.clearSyncedData()).thenThrow(StateError('x'));
      expect(await failureOf(), isA<CacheFailure>());
    },
  );

  test('success runs every step in order', () async {
    harness.signedIn = true;
    harness.serverClears();

    expect(
      await harness.repository.deleteAllData(),
      const Right<Failure, Unit>(unit),
    );
    expect(harness.calls, [
      'pauseSync',
      'clearServer',
      'wipe',
      'resetSettings',
      'cancelScheduledWork',
      'clearLocalPrefs',
      'resetSyncState',
      'resumeSync',
    ]);
  });
}
