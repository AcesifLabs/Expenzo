import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/factories/budget_factory.dart';

class _MockBudgets extends Mock implements BudgetRepository {}

void main() {
  late db.AppDatabase database;
  late _MockBudgets budgets;
  late GetBudgetsWithProgress useCase;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    budgets = _MockBudgets();
    useCase = GetBudgetsWithProgress(
      budgetRepository: budgets,
      recordRepository: RecordRepositoryImpl(
        localDatasource: RecordLocalDatasourceImpl(
          recordDao: RecordDao(database),
        ),
      ),
    );
  });

  tearDown(() => database.close());

  Future<void> spend(String id, double amount, DateTime date) => database
      .into(database.records)
      .insert(
        db.RecordsCompanion.insert(
          id: id,
          amount: -amount,
          description: id,
          date: date,
          recordType: 'OUT',
          budgetId: const Value('b'),
        ),
      );

  test('May left 150 unspent, so June has 650', () async {
    when(() => budgets.getBudgets()).thenAnswer(
      (_) async => Right([
        makeBudget(
          id: 'b',
          amount: 500,
          startDate: DateTime(2026, 1, 1),
          rolloverEnabled: true,
        ),
      ]),
    );
    await spend('may', 350, DateTime(2026, 5, 10));
    await spend('june', 100, DateTime(2026, 6, 3));

    final result = await withClock(
      Clock.fixed(DateTime(2026, 6, 15)),
      () => useCase(),
    );
    final progress = result.getOrElse(() => []).single;

    expect(progress.rolloverAmount, 150);
    expect(progress.effectiveAmount, 650);
    expect(progress.spentAmount, 100);
  });
}
