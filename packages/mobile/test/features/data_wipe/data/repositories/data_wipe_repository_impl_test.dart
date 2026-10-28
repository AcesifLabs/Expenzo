import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/data_wipe/domain/entities/local_data_summary.dart';

import 'data_wipe_test_harness.dart';

void main() {
  late DataWipeHarness harness;

  setUp(() async {
    harness = DataWipeHarness();
    await harness.setUp();
  });

  tearDown(() => harness.db.close());

  group('wipeLocalData', () {
    test('leaves the 18 default categories and keeps the user row', () async {
      expect(
        await harness.repository.wipeLocalData(),
        const Right<Failure, Unit>(unit),
      );

      expect(await harness.recordCount(), 0);
      expect(await harness.categoryCount(), 18);
      expect(await harness.userCount(), 1);
    });

    test(
      'resets settings, cancels scheduled work, then clears prefs',
      () async {
        await harness.repository.wipeLocalData();

        expect(harness.calls, [
          'wipe',
          'resetSettings',
          'cancelScheduledWork',
          'clearLocalPrefs',
        ]);
        expect(
          harness.prefs.getKeys(),
          isNot(contains('budget_names_repaired_u1')),
        );
        expect(harness.prefs.getString('user_settings'), contains('"BDT"'));
      },
    );

    test('never calls the server or the sync hooks', () async {
      await harness.repository.wipeLocalData();

      verifyNever(() => harness.remote.clearSyncedData());
      expect(
        harness.calls,
        isNot(anyOf(contains('pauseSync'), contains('resumeSync'))),
      );
    });

    test('a failed database wipe gives CacheFailure and stops', () async {
      harness.wipeFails = true;

      final result = await harness.repository.wipeLocalData();

      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
      expect(harness.calls, ['wipe']);
    });

    test('a failing later step still completes the wipe', () async {
      harness.cancelError = Exception('plugin missing');

      expect(
        await harness.repository.wipeLocalData(),
        const Right<Failure, Unit>(unit),
      );
      expect(harness.calls.last, 'clearLocalPrefs');
    });
  });

  group('countData', () {
    test('returns the seeded counts', () async {
      final result = await harness.repository.countData();

      expect(
        result,
        const Right<Failure, LocalDataSummary>(
          LocalDataSummary(
            transactions: 2,
            budgets: 1,
            categories: 3,
            recurring: 1,
            smsRules: 1,
            goals: 0,
          ),
        ),
      );
    });

    test('a database error gives CacheFailure', () async {
      await harness.db.close();

      final result = await harness.repository.countData();

      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });
  });

  test('isSignedIn returns the hook value', () async {
    harness.signedIn = true;

    expect(await harness.repository.isSignedIn(), isTrue);
  });
}
