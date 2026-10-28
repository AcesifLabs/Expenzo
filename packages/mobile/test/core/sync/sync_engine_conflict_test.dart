import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/handlers/records_sync_handler.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'sync_engine_harness.dart';

void main() {
  late SyncEngineHarness harness;

  setUp(() => harness = SyncEngineHarness()..setUp());

  tearDown(() => harness.tearDown());

  void summaryReturns(Object? body) =>
      when(() => harness.dio.get<Object?>(ApiConstants.syncSummary)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.syncSummary),
          data: body,
        ),
      );

  test('an unreachable summary throws instead of reading as empty', () {
    when(
      () => harness.dio.get<Object?>(ApiConstants.syncSummary),
    ).thenThrow(DioException(requestOptions: RequestOptions()));

    expect(harness.engine().checkConflict(), throwsA(isA<DioException>()));
  });

  test('a summary without a count throws', () {
    summaryReturns({'unexpected': true});

    expect(harness.engine().checkConflict(), throwsFormatException);
  });

  test('an empty account with no local data is no conflict', () async {
    summaryReturns({'totalCount': 0});

    expect(await harness.engine().checkConflict(), SyncConflictType.none);
  });

  test('Sync now before the first sync asks for the conflict check', () async {
    FlutterSecureStorage.setMockInitialValues({'jwt_access_token': 'token'});
    final sync = harness.engine();
    final asked = expectLater(sync.firstSyncNeeded, emits(null));

    expect(await sync.syncNow(), SyncRunResult.firstSyncPending);
    await asked;
  });

  test('Sync now after a partly failed first upload does not ask again: the '
      'account holds this phone\'s own data', () async {
    FlutterSecureStorage.setMockInitialValues({'jwt_access_token': 'token'});
    await harness.db.customStatement(
      'INSERT INTO records (id, amount, description, date, record_type) '
      "VALUES ('r1', -5, 'Tea', 0, 'OUT')",
    );
    harness.pushThrows();
    final sync = harness.engine(
      registry: SyncTableRegistry()..register(RecordsSyncHandler()),
    );
    var asked = false;
    final sub = sync.firstSyncNeeded.listen((_) => asked = true);
    addTearDown(sub.cancel);
    await sync.start();

    expect(await sync.syncNow(), SyncRunResult.firstSyncPending);
    await pumpEventQueue();

    expect(asked, isFalse);
  });
}
