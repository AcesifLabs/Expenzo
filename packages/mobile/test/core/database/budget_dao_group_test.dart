import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/shared_budget_rows.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('getBudgetsWithGroup returns only shared budgets', () async {
    await insertBudgetRow(db, 'personal');
    await insertBudgetRow(db, 'shared', groupId: 'group-1');

    final rows = await db.budgetDao.getBudgetsWithGroup();

    expect(rows.map((r) => r.id), ['shared']);
  });

  test('deleteBudgetsByIds leaves linked records and their budgetId', () async {
    await insertBudgetRow(db, 'shared', groupId: 'group-1');
    await db
        .into(db.records)
        .insert(
          RecordsCompanion.insert(
            id: 'rec-1',
            amount: -10,
            description: 'x',
            date: DateTime(2026, 1, 15),
            recordType: 'OUT',
            budgetId: const Value('shared'),
          ),
        );

    await db.budgetDao.deleteBudgetsByIds(['shared']);

    expect(await budgetGroupIds(db), isEmpty);
    final record = await db.select(db.records).getSingle();
    expect(record.budgetId, 'shared');
  });

  test('clearGroupId makes the budgets personal', () async {
    await insertBudgetRow(db, 'shared', groupId: 'group-1');

    await db.budgetDao.clearGroupId(['shared']);

    expect(await budgetGroupIds(db), {'shared': null});
  });

  test('pendingRecordIds lists unsynced rows of one table', () async {
    await db.syncQueueDao.enqueue(
      tableName: 'budgets',
      recordId: 'b-1',
      action: 'update',
      payload: '{}',
    );
    await db.syncQueueDao.enqueue(
      tableName: 'records',
      recordId: 'r-1',
      action: 'update',
      payload: '{}',
    );

    expect(await db.syncQueueDao.pendingRecordIds('budgets'), {'b-1'});
  });
}
