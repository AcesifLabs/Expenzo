import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/sync/sync_outcome_store.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('a recorded success reads back in local time', () async {
    final time = DateTime(2026, 10, 15, 9, 30, 12, 345);

    await SyncOutcomeStore.recordSyncSuccess(time);

    expect(await SyncOutcomeStore.getLastSuccessfulSyncAt(), time);
    expect((await SyncOutcomeStore.getLastSuccessfulSyncAt())!.isUtc, isFalse);
  });

  test('a failure keeps the last success time', () async {
    await SyncOutcomeStore.recordSyncSuccess(DateTime(2026, 10, 15, 8));
    await SyncOutcomeStore.recordSyncFailure(DateTime(2026, 10, 15, 9));

    expect(
      await SyncOutcomeStore.getLastSuccessfulSyncAt(),
      DateTime(2026, 10, 15, 8),
    );
  });

  test('an unreadable count still keeps the success time', () async {
    await SyncOutcomeStore.recordSyncSuccess(DateTime(2026, 10, 15, 8));
    FlutterSecureStorage.setMockInitialValues({
      'last_successful_sync_at': DateTime(
        2026,
        10,
        15,
        8,
      ).toUtc().toIso8601String(),
      'consecutive_sync_failures': 'x',
    });

    await SyncOutcomeStore.recordSyncFailure(DateTime(2026, 10, 15, 9));

    expect(
      await SyncOutcomeStore.getLastSuccessfulSyncAt(),
      DateTime(2026, 10, 15, 8),
    );
    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 1);
  });

  test('failures count up and a success clears them', () async {
    for (var i = 0; i < 3; i++) {
      await SyncOutcomeStore.recordSyncFailure(DateTime(2026, 10, 15, 9, i));
    }

    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 3);
    expect(
      await SyncOutcomeStore.getLastFailedSyncAt(),
      DateTime(2026, 10, 15, 9, 2),
    );

    await SyncOutcomeStore.recordSyncSuccess(DateTime(2026, 10, 15, 10));

    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 0);
    expect(await SyncOutcomeStore.getLastFailedSyncAt(), isNull);
  });

  test('clear forgets the sync history', () async {
    await SyncOutcomeStore.recordSyncSuccess(DateTime(2026));
    await SyncOutcomeStore.recordSyncFailure(DateTime(2026, 2));

    await SyncOutcomeStore.clear();

    expect(await SyncOutcomeStore.getLastSuccessfulSyncAt(), isNull);
    expect(await SyncOutcomeStore.getLastFailedSyncAt(), isNull);
    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 0);
  });
}
