import 'package:drift/native.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late db.AppDatabase database;
  late RecordRepositoryImpl repository;
  late SyncQueueDao queue;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    queue = SyncQueueDao(database);
    repository = RecordRepositoryImpl(
      localDatasource: RecordLocalDatasourceImpl(
        recordDao: RecordDao(database),
      ),
      syncQueueDao: queue,
    );
  });

  tearDown(() => database.close());

  Record sms(String sourceId) => Record(
    amount: -250,
    description: 'Groceries',
    date: DateTime(2026, 10, 1),
    source: ExpenseSource.sms,
    sourceId: sourceId,
    recordType: RecordType.expense,
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
  );

  test('importing the same SMS twice keeps one record and syncs one', () async {
    await repository.addRecordsBatch([sms('sms-1')]);
    await repository.addRecordsBatch([sms('sms-1'), sms('sms-2')]);

    final rows = await database.select(database.records).get();
    expect(rows.map((r) => r.sourceId), unorderedEquals(['sms-1', 'sms-2']));
    expect(await queue.getUnsynced(), hasLength(2));
  });

  test('a batch asks for one sync, not one per record', () async {
    var triggers = 0;
    final sub = SyncEventBus().events.listen((_) => triggers++);
    addTearDown(sub.cancel);

    await repository.addRecordsBatch([
      sms('sms-1'),
      sms('sms-2'),
      sms('sms-3'),
    ]);
    await pumpEventQueue();

    expect(triggers, 1);
    expect(await queue.getUnsynced(), hasLength(3));
  });
}
