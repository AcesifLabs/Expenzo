import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RecordDao dao;

  setUp(
    () => dao = RecordDao(db = AppDatabase.forTesting(NativeDatabase.memory())),
  );

  tearDown(() => db.close());

  Future<void> insert(String id, String sourceId, double amount) => db
      .into(db.records)
      .insert(
        RecordsCompanion.insert(
          id: id,
          amount: amount,
          description: 'SMS',
          date: DateTime(2026, 10, 1),
          recordType: amount < 0 ? 'OUT' : 'IN',
          sourceId: Value(sourceId),
          source: const Value('sms'),
        ),
      );

  test('amounts are absolute and grouped by source id', () async {
    await insert('r1', '12345', -500);
    await insert('r2', '99999', 20);

    expect(await dao.getAmountsBySourceIds(['12345', '77777']), {
      '12345': [500.0],
    });
  });

  test('copies the v20 migration renamed count under their old id', () async {
    await insert('r1', '12345', -500);
    await insert('r2', '12345#7', -75);
    await insert('r3', '123456', -1);

    final amounts = await dao.getAmountsBySourceIds(['12345']);

    expect(amounts.keys, ['12345']);
    expect(amounts['12345'], unorderedEquals([500.0, 75.0]));
  });

  test('a batch insert returns only the rows it added', () async {
    await insert('r1', '12345', -500);
    RecordsCompanion sms(String id, String sourceId) => RecordsCompanion.insert(
      id: id,
      amount: -10,
      description: 'SMS',
      date: DateTime(2026, 10, 1),
      recordType: 'OUT',
      sourceId: Value(sourceId),
      source: const Value('sms'),
    );

    final inserted = await dao.insertRecordsBatch([
      sms('r2', '12345'),
      sms('r3', '67890'),
      sms('r1', '55555'),
      for (var i = 0; i < 600; i++) sms('bulk$i', 'bulk$i'),
    ]);

    expect(inserted, {'r3', for (var i = 0; i < 600; i++) 'bulk$i'});
  });
}
