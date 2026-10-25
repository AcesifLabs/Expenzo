import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/goals_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/recurring_dao.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_tracker/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/factories/budget_factory.dart';
import '../../support/factories/record_factory.dart';
import '../../support/factories/recurring_factory.dart';

/// ADR 0014: every stored amount keeps 2 decimals, whatever the caller
/// passes in.
void main() {
  late db.AppDatabase database;

  setUp(() => database = db.AppDatabase.forTesting(NativeDatabase.memory()));

  tearDown(() => database.close());

  group('records', () {
    late RecordLocalDatasourceImpl records;

    setUp(
      () => records = RecordLocalDatasourceImpl(recordDao: RecordDao(database)),
    );

    Future<double> storedAmount(String id) async => (await (database.select(
      database.records,
    )..where((r) => r.id.equals(id))).getSingle()).amount;

    test('add', () async {
      await records.addRecord(makeRecord(id: 'a', amount: -12.345));

      expect(await storedAmount('a'), -12.35);
    });

    test('update', () async {
      await records.addRecord(makeRecord(id: 'a', amount: -1));
      await records.updateRecord(makeRecord(id: 'a', amount: -7.004));

      expect(await storedAmount('a'), -7.0);
    });

    test('batch', () async {
      await records.addRecordsBatch([makeRecord(id: 'b', amount: -0.126)]);

      expect(await storedAmount('b'), -0.13);
    });
  });

  test('budgets round the amount and the rollover', () async {
    final budgets = BudgetLocalDatasourceImpl(budgetDao: BudgetDao(database));
    await budgets.createBudget(
      makeBudget(id: 'b', amount: 99.999).copyWith(rolloverAmount: 10.005),
    );

    final row = await database.select(database.budgets).getSingle();
    expect(row.amount, 100.0);
    expect(row.rolloverAmount, closeTo(10.01, 0.001));
  });

  test('goals round the target and the saved amount', () async {
    final goals = GoalLocalDatasourceImpl(goalsDao: GoalsDao(database));
    await goals.createGoal(
      const Goal(
        id: 'g',
        name: 'Bike',
        targetAmount: 500.555,
        savedAmount: 1.234,
      ),
    );

    final row = await database.select(database.goals).getSingle();
    expect(row.targetAmount, closeTo(500.56, 0.001));
    expect(row.savedAmount, 1.23);
  });

  test('recurring items round the amount', () async {
    final recurring = RecurringLocalDatasourceImpl(
      recurringDao: RecurringDao(database),
    );
    await recurring.createRecurring(makeRecurring(id: 'r', amount: 49.999));

    final row = await database
        .select(database.recurringTransactions)
        .getSingle();
    expect(row.amount, 50.0);
  });
}
