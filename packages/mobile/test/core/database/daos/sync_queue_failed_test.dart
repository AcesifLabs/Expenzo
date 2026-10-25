import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SyncQueueDao queue;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queue = SyncQueueDao(db);
    await queue.enqueue(
      tableName: 'records',
      recordId: 'r1',
      action: 'update',
      payload: '{}',
    );
  });

  tearDown(() => db.close());

  Future<int> onlyId() async => (await queue.getUnsynced()).single.id;

  test('a change rejected 4 times is still pending', () async {
    final id = await onlyId();
    for (var i = 0; i < 4; i++) {
      await queue.recordRejected([id]);
    }

    expect(await queue.getUnsynced(), hasLength(1));
    expect(await queue.watchFailedCount().first, 0);
  });

  test('the 5th rejection makes it a Failed Sync Change', () async {
    final id = await onlyId();
    for (var i = 0; i < SyncQueueDao.maxAttempts; i++) {
      await queue.recordRejected([id]);
    }

    expect(await queue.getUnsynced(), isEmpty);
    expect(await queue.getUnsyncedCount(), 0);
    expect(await queue.watchFailedCount().first, 1);
  });

  test('Retry puts it back with a fresh count', () async {
    final id = await onlyId();
    for (var i = 0; i < SyncQueueDao.maxAttempts; i++) {
      await queue.recordRejected([id]);
    }

    await queue.retryFailed();

    final again = (await queue.getUnsynced()).single;
    expect(again.attemptCount, 0);
    expect(again.failedAt, isNull);
    expect(await queue.watchFailedCount().first, 0);
  });

  group('Retry skips what a newer change replaced', () {
    Future<void> failAll() async {
      final ids = [for (final item in await queue.getUnsynced()) item.id];
      for (var i = 0; i < SyncQueueDao.maxAttempts; i++) {
        await queue.recordRejected(ids);
      }
    }

    test('a failed edit of a record deleted since stays deleted', () async {
      await failAll();
      await queue.enqueue(
        tableName: 'records',
        recordId: 'r1',
        action: 'delete',
        payload: '',
      );
      final delete = (await queue.getUnsynced()).single;
      await queue.markSynced([delete.id]);

      await queue.retryFailed();

      expect(await queue.getUnsynced(), isEmpty);
    });

    test('a failed edit replaced by a newer edit is not sent', () async {
      await failAll();
      await queue.enqueue(
        tableName: 'records',
        recordId: 'r1',
        action: 'update',
        payload: '{"amount": -20}',
      );

      await queue.retryFailed();

      final pending = await queue.getUnsynced();
      expect(pending.map((p) => p.payload), ['{"amount": -20}']);
    });

    test(
      'an empty usage-count update does not replace a failed edit',
      () async {
        await failAll();
        await queue.enqueue(
          tableName: 'records',
          recordId: 'r1',
          action: 'update',
          payload: '',
        );

        await queue.retryFailed();

        expect((await queue.getUnsynced()).map((p) => p.payload), ['{}', '']);
      },
    );

    test('a newer edit does not replace a failed insert', () async {
      await queue.enqueue(
        tableName: 'categories',
        recordId: 'c1',
        action: 'insert',
        payload: '{"name": "Food"}',
      );
      await failAll();
      await queue.enqueue(
        tableName: 'categories',
        recordId: 'c1',
        action: 'update',
        payload: '{"name": "Groceries"}',
      );

      await queue.retryFailed();

      expect(
        (await queue.getUnsynced())
            .where((p) => p.recordId == 'c1')
            .map((p) => p.action),
        ['insert', 'update'],
      );
    });

    test('a failed change of another record is still retried', () async {
      await failAll();
      await queue.enqueue(
        tableName: 'records',
        recordId: 'r2',
        action: 'update',
        payload: '{}',
      );

      await queue.retryFailed();

      expect(
        (await queue.getUnsynced()).map((p) => p.recordId),
        unorderedEquals(['r1', 'r2']),
      );
    });
  });

  test('changes sent over 30 days ago are pruned; pending ones stay', () async {
    final id = await onlyId();
    await queue.markSynced([id]);
    await queue.enqueue(
      tableName: 'records',
      recordId: 'r2',
      action: 'update',
      payload: '{}',
    );

    final pruned = await queue.deleteSentBefore(
      DateTime.now().add(const Duration(days: 31)),
    );

    expect(pruned, 1);
    expect((await queue.getUnsynced()).map((p) => p.recordId), ['r2']);
  });
}
