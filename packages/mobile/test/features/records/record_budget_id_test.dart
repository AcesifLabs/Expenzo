import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/sync/handlers/records_sync_handler.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';

import '../../support/factories/record_factory.dart';

void main() {
  late AppDatabase db;
  late RecordLocalDatasourceImpl datasource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = RecordLocalDatasourceImpl(recordDao: RecordDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('persists and reads back a record budgetId', () async {
    final record = makeRecord(id: 'r-with-budget', budgetId: 'budget-42');

    await datasource.addRecord(record);
    final read = await datasource.getRecordById('r-with-budget');

    expect(read, isNotNull);
    expect(read!.budgetId, 'budget-42');
  });

  test('a record with no budget link reads back as null budgetId', () async {
    final record = makeRecord(id: 'r-no-budget', budgetId: null);

    await datasource.addRecord(record);
    final read = await datasource.getRecordById('r-no-budget');

    expect(read!.budgetId, isNull);
  });

  test('sync payload round-trips budgetId', () async {
    final handler = RecordsSyncHandler();

    // Insert a row via the sync inbound path carrying a budgetId.
    final companion = handler.fromSyncPayload('sync-r1', {
      'amount': -30.0,
      'description': 'Synced expense',
      'date': DateTime(2026, 1, 1).toUtc().toIso8601String(),
      'budgetId': 'budget-sync',
      'recordType': 'OUT',
    });
    await db.into(db.records).insert(companion);

    final row = await (db.select(
      db.records,
    )..where((t) => t.id.equals('sync-r1'))).getSingle();

    // Outbound payload preserves the budgetId.
    final payload = handler.toSyncPayload(row);
    expect(payload['budgetId'], 'budget-sync');
  });
}
