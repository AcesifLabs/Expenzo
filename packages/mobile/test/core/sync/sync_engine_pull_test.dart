import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/sync/handlers/records_sync_handler.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'sync_engine_harness.dart';

const _serverTime = '2026-10-20T00:00:00.000Z';

Map<String, dynamic> _record(String id, Object amount, String updatedAt) => {
  'table': 'records',
  'action': 'insert',
  'id': id,
  'updatedAt': updatedAt,
  'data': {
    'amount': amount,
    'description': id,
    'date': '2026-10-01T00:00:00.000Z',
    'recordType': 'OUT',
  },
};

void main() {
  late SyncEngineHarness harness;

  setUp(() {
    harness = SyncEngineHarness()..setUp();
  });

  tearDown(() => harness.tearDown());

  SyncTableRegistry records() =>
      SyncTableRegistry()..register(RecordsSyncHandler());

  void pullChanges(List<Map<String, dynamic>> changes) => harness.pullWith(
    () async => Response(
      requestOptions: RequestOptions(path: ApiConstants.syncPull),
      data: {'changes': changes, 'serverTime': _serverTime},
    ),
  );

  List<String?> sentCursors() => verify(
    () => harness.dio.get<Object?>(
      ApiConstants.syncPull,
      queryParameters: captureAny(named: 'queryParameters'),
    ),
  ).captured.map((q) => (q as Map)['since'] as String?).toList();

  Future<Set<String>> savedIds() async =>
      (await harness.db.select(harness.db.records).get())
          .map((r) => r.id)
          .toSet();

  test('a row that fails to apply is pulled again next time', () async {
    pullChanges([
      _record('r1', -10, '2026-10-01T00:00:00.000Z'),
      _record('r2', 'not a number', '2026-10-02T00:00:00.000Z'),
      _record('r3', -30, '2026-10-03T00:00:00.000Z'),
    ]);
    final sync = harness.engine(registry: records());

    await sync.syncNow();

    expect(await savedIds(), {'r1', 'r3'});
    expect(await TokenStorage.getLastSyncAt(), '2026-10-01T23:59:59.999Z');

    await sync.syncNow();

    expect(sentCursors().last, '2026-10-01T23:59:59.999Z');
  });

  test('when every row applies the cursor moves to the server time', () async {
    pullChanges([_record('r1', -10, '2026-10-01T00:00:00.000Z')]);

    await harness.engine(registry: records()).syncNow();

    expect(await TokenStorage.getLastSyncAt(), _serverTime);
  });

  test('a row that fails 5 pulls in a row stops holding the cursor', () async {
    pullChanges([_record('bad', 'x', '2026-10-02T00:00:00.000Z')]);
    final sync = harness.engine(registry: records());

    for (var i = 0; i < 4; i++) {
      await sync.syncNow();
      expect(await TokenStorage.getLastSyncAt(), isNot(_serverTime));
    }
    await sync.syncNow();

    expect(await TokenStorage.getLastSyncAt(), _serverTime);
  });

  test('a failed pull schedules a retry', () async {
    harness.pullThrows();
    final sync = harness.engine();

    await sync.syncNow();

    expect(sync.hasPendingRetry, isTrue);
  });

  test('after many failures the engine keeps retrying, hourly', () async {
    harness.pullThrows();
    final sync = harness.engine();
    await sync.syncNow();

    for (var i = 0; i < 10; i++) {
      await sync.runScheduledRetry();
    }

    expect(sync.hasPendingRetry, isTrue);
    expect(sync.scheduledRetryDelay, const Duration(hours: 1));
  });

  test(
    'a cycle that works, even with nothing to push, resets the backoff',
    () async {
      harness.pullThrows();
      final sync = harness.engine();
      await sync.syncNow();
      for (var i = 0; i < 4; i++) {
        await sync.runScheduledRetry();
      }

      harness.pullReturns();
      await sync.runScheduledRetry();
      harness.pullThrows();
      await sync.syncNow();

      expect(sync.scheduledRetryDelay, const Duration(seconds: 5));
    },
  );

  test(
    'a push that works doesn\'t reset the backoff of a failing pull',
    () async {
      harness
        ..pullThrows()
        ..pushSucceeds();
      final sync = harness.engine();
      await harness.queueChange();
      await sync.syncNow();
      await harness.queueChange('r2');
      await sync.runScheduledRetry();
      final second = sync.scheduledRetryDelay;

      await harness.queueChange('r3');
      await sync.runScheduledRetry();

      expect(sync.scheduledRetryDelay, greaterThan(second!));
    },
  );

  test('a row held for an edit that can\'t be pushed stops pinning the '
      'cursor after 5 pulls', () async {
    await harness.queue.enqueue(
      tableName: 'records',
      recordId: 'r1',
      action: 'update',
      payload: '{}',
    );
    harness.pushThrows();
    pullChanges([_record('r1', -10, '2026-10-01T00:00:00.000Z')]);
    final sync = harness.engine(registry: records());

    for (var i = 0; i < 4; i++) {
      await sync.syncNow();
      expect(await TokenStorage.getLastSyncAt(), isNot(_serverTime));
    }
    await sync.syncNow();

    expect(await TokenStorage.getLastSyncAt(), _serverTime);
  });

  test(
    'a failed row without a time does not reset the cursor to the start',
    () async {
      pullChanges([
        {..._record('bad', 'x', ''), 'updatedAt': null},
      ]);

      await harness.engine(registry: records()).syncNow();

      expect(await TokenStorage.getLastSyncAt(), _serverTime);
    },
  );
}
