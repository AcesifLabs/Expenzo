import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';

void main() {
  late AppDatabase db;
  late BudgetDao budgetDao;
  late RecordDao recordDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    budgetDao = BudgetDao(db);
    recordDao = RecordDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertBudget(String id) {
    return budgetDao.insertBudget(
      BudgetsCompanion.insert(
        id: id,
        name: 'B',
        amount: 100,
        period: 'monthly',
        startDate: DateTime(2026, 1, 1),
      ),
    );
  }

  Future<void> insertRecord(String id, {String? budgetId}) {
    return recordDao.insertRecord(
      RecordsCompanion.insert(
        id: id,
        amount: -10,
        description: 'x',
        date: DateTime(2026, 1, 15),
        recordType: 'OUT',
        budgetId: Value(budgetId),
      ),
    );
  }

  test(
    'deletes the budget, unlinks its records, and returns affected ids',
    () async {
      await insertBudget('b1');
      await insertRecord('r1', budgetId: 'b1');
      await insertRecord('r2', budgetId: 'b1');
      await insertRecord('r3', budgetId: 'b2'); // other budget
      await insertRecord('r4'); // unlinked

      final affected = await budgetDao.deleteBudgetAndUnlinkRecords('b1');

      // Budget is gone.
      expect(await budgetDao.getBudgetById('b1'), null);

      // Linked records are unlinked; others untouched.
      final r1 = await recordDao.getRecordById('r1');
      final r2 = await recordDao.getRecordById('r2');
      final r3 = await recordDao.getRecordById('r3');
      expect(r1!.budgetId, null);
      expect(r2!.budgetId, null);
      expect(r3!.budgetId, 'b2');

      // Affected records returned (already unlinked) for sync enqueue.
      expect(affected.map((r) => r.id).toSet(), {'r1', 'r2'});
      expect(affected.every((r) => r.budgetId == null), isTrue);
    },
  );

  test('returns empty when the budget has no linked records', () async {
    await insertBudget('b1');
    await insertRecord('r1', budgetId: 'other');

    final affected = await budgetDao.deleteBudgetAndUnlinkRecords('b1');

    expect(affected, isEmpty);
    expect(await budgetDao.getBudgetById('b1'), null);
  });
}
