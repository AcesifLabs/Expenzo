import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart'
    as domain;

void main() {
  late AppDatabase db;
  late BudgetLocalDatasourceImpl datasource;

  domain.Budget budget(String id, String name) => domain.Budget(
    id: id,
    name: name,
    amount: 100,
    period: BudgetPeriod.monthly,
    startDate: DateTime(2026, 10),
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = BudgetLocalDatasourceImpl(budgetDao: BudgetDao(db));
    await datasource.createBudget(budget('rent', 'Rent'));
    await datasource.createBudget(budget('gone', 'Gone'));
  });

  tearDown(() => db.close());

  Future<List<String>> names() async => [
    for (final b in await datasource.getBudgets()) b.name,
  ];

  test('applies deletes, updates and creates together', () async {
    await datasource.applyPlanChanges(
      deleteIds: ['gone'],
      updates: [budget('rent', 'Housing')],
      creates: [budget('travel', 'Travel')],
    );

    expect(await names(), unorderedEquals(['Housing', 'Travel']));
  });

  test('a failing create rolls back the whole save', () async {
    await expectLater(
      datasource.applyPlanChanges(
        deleteIds: ['gone'],
        updates: [budget('rent', 'Housing')],
        creates: [budget('rent', 'Duplicate id')],
      ),
      throwsA(anything),
    );

    expect(await names(), unorderedEquals(['Rent', 'Gone']));
  });
}
