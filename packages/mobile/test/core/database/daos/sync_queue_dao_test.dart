import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';

void main() {
  late AppDatabase db;
  late SyncQueueDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SyncQueueDao(db);
  });

  tearDown(() => db.close());

  Future<void> enqueue(String id) => dao.enqueue(
    tableName: 'records',
    recordId: id,
    action: 'create',
    payload: '{}',
  );

  test('watchUnsyncedCount follows enqueue and markSynced', () async {
    final counts = <int>[];
    final sub = dao.watchUnsyncedCount().listen(counts.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await enqueue('a');
    await enqueue('b');
    await pumpEventQueue();
    final first = (await dao.getUnsynced()).first;
    await dao.markSynced([first.id]);
    await pumpEventQueue();

    expect(counts.first, 0);
    expect(counts.last, 1);
    expect(counts, contains(2));
  });
}
