import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/sync/sync_outcome_store.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('clearSyncState forgets the sync history', () async {
    await SyncOutcomeStore.recordSyncSuccess(DateTime(2026));
    await SyncOutcomeStore.recordSyncFailure(DateTime(2026, 2));

    await TokenStorage.clearSyncState();

    expect(await SyncOutcomeStore.getLastSuccessfulSyncAt(), isNull);
    expect(await SyncOutcomeStore.getLastFailedSyncAt(), isNull);
    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 0);
  });
}
