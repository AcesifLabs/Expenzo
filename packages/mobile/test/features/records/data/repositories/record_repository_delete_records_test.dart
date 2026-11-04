import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';

import '../../../../support/factories/record_factory.dart';

void main() {
  late db.AppDatabase database;
  late SyncQueueDao queue;
  late RecordRepositoryImpl repository;

  setUp(() async {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    queue = SyncQueueDao(database);
    repository = RecordRepositoryImpl(
      localDatasource: RecordLocalDatasourceImpl(
        recordDao: RecordDao(database),
      ),
      syncQueueDao: queue,
    );
    await repository.addRecordsBatch([
      makeRecord(id: 'rec-1', description: 'Coffee'),
      makeRecord(id: 'rec-2', description: 'Lunch'),
      makeRecord(id: 'rec-3', description: 'Taxi'),
    ]);
  });

  tearDown(() => database.close());

  Future<List<String?>> remainingIds() async => (await repository.getRecords())
      .getOrElse(() => throw StateError('read failed'))
      .map((r) => r.id)
      .toList();

  test('deletes the ids together and queues one sync delete each', () async {
    final result = await repository.deleteRecords(['rec-1', 'rec-3']);

    expect(result.getOrElse(() => {}), {'rec-1', 'rec-3'});
    expect(await remainingIds(), ['rec-2']);
    final deletes = (await queue.getUnsynced()).where(
      (row) => row.action == 'delete',
    );
    expect(deletes.map((row) => row.recordId).toSet(), {'rec-1', 'rec-3'});
    expect(deletes.every((row) => row.payload.isEmpty), isTrue);
  });

  test('ids that are already gone are not reported or queued', () async {
    final result = await repository.deleteRecords(['rec-2', 'missing']);

    expect(result.getOrElse(() => {}), {'rec-2'});
    final deletes = (await queue.getUnsynced()).where(
      (row) => row.action == 'delete',
    );
    expect(deletes.map((row) => row.recordId), ['rec-2']);
  });

  test('restoring the deleted records brings them back', () async {
    final all = (await repository.getRecords()).getOrElse(() => []);
    await repository.deleteRecords(['rec-1', 'rec-2', 'rec-3']);

    await repository.addRecordsBatch(all);

    expect((await remainingIds()).toSet(), {'rec-1', 'rec-2', 'rec-3'});
  });
}
