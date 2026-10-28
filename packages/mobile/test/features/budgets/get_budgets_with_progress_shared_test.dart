import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/family/data/services/shared_spent_lookup.dart';
import 'package:expense_tracker/features/family/domain/entities/group_summary.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/factories/budget_factory.dart';
import '../../support/factories/family_factory.dart';

class _MockRecordRepository extends Mock implements RecordRepository {}

class _MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late _MockRecordRepository records;
  late _MockBudgetRepository budgets;
  final now = DateTime.now();
  final periodStart = DateTime(now.year, now.month);

  setUpAll(
    () => registerFallbackValue(<String, ({DateTime start, DateTime end})>{}),
  );

  setUp(() {
    records = _MockRecordRepository();
    budgets = _MockBudgetRepository();
    when(
      () => records.getSpendingForBudgets(any()),
    ).thenAnswer((_) async => const Right({'shared': 10, 'personal': 20}));
    when(() => budgets.getBudgets()).thenAnswer(
      (_) async => Right([
        makeBudget(
          id: 'shared',
          amount: 100,
          startDate: periodStart,
          groupId: 'group-1',
        ),
        makeBudget(id: 'personal', amount: 100, startDate: periodStart),
      ]),
    );
  });

  Future<Map<String, double>> spent(SharedSpentLookup? lookup) async {
    final result = await GetBudgetsWithProgress(
      budgetRepository: budgets,
      recordRepository: records,
      sharedSpent: lookup ?? (_, _) => null,
    )();
    final progress = result.getOrElse(() => const []);

    return {for (final p in progress) p.budgetId: p.spentAmount};
  }

  test(
    'a shared budget uses the server spent, a personal one local spend',
    () async {
      expect(await spent((_, _) => 75), {'shared': 75, 'personal': 20});
    },
  );

  test('falls back to local spend when the server has none', () async {
    expect(await spent((_, _) => null), {'shared': 10, 'personal': 20});
    expect(await spent(null), {'shared': 10, 'personal': 20});
  });

  test('sets groupId on the progress', () async {
    final result = await GetBudgetsWithProgress(
      budgetRepository: budgets,
      recordRepository: records,
      sharedSpent: (_, _) => null,
    )();

    final byId = {
      for (final p in result.getOrElse(() => const [])) p.budgetId: p.groupId,
    };
    expect(byId, {'shared': 'group-1', 'personal': null});
  });

  group('sharedSpentFromSummary', () {
    GroupSummary summaryFrom(DateTime start) => makeGroupSummary(
      spent: 75,
      sharedBudgets: [
        SharedBudgetProgress(
          id: 'shared',
          name: 'Groceries',
          period: BudgetPeriod.monthly,
          amount: 100,
          effectiveAmount: 100,
          spent: 75,
          periodStart: start.toUtc(),
          periodEnd: start.toUtc(),
        ),
      ],
    );

    test('returns spent for the same period', () {
      final lookup = sharedSpentFromSummary(() => summaryFrom(periodStart));

      expect(lookup('shared', periodStart), 75);
    });

    test('returns null for a summary of an earlier period', () {
      final lookup = sharedSpentFromSummary(
        () => summaryFrom(DateTime(now.year, now.month - 1)),
      );

      expect(lookup('shared', periodStart), isNull);
    });

    test('returns null for an unknown budget or no summary', () {
      expect(
        sharedSpentFromSummary(() => summaryFrom(periodStart))(
          'other',
          periodStart,
        ),
        isNull,
      );
      expect(sharedSpentFromSummary(() => null)('shared', periodStart), isNull);
    });
  });
}
