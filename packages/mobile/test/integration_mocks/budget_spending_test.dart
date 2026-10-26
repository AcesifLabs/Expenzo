import 'package:clock/clock.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';

import '../support/factories/budget_factory.dart';

class MockRecordRepository extends Mock implements RecordRepository {}

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late MockRecordRepository mockRecordRepository;
  late MockBudgetRepository mockBudgetRepository;
  late GetBudgetsWithProgress getBudgetsWithProgress;

  final now = DateTime.now();
  final periodStart = DateTime(now.year, now.month, 1);

  setUp(() {
    mockRecordRepository = MockRecordRepository();
    mockBudgetRepository = MockBudgetRepository();
    getBudgetsWithProgress = GetBudgetsWithProgress(
      budgetRepository: mockBudgetRepository,
      recordRepository: mockRecordRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(<String, ({DateTime start, DateTime end})>{});
  });

  void stubSpendByBudget(Map<String, double> spendById) {
    when(() => mockRecordRepository.getSpendingForBudgets(any())).thenAnswer((
      invocation,
    ) async {
      final periods =
          invocation.positionalArguments[0]
              as Map<String, ({DateTime start, DateTime end})>;
      return Right({for (final id in periods.keys) id: spendById[id] ?? 0.0});
    });
  }

  group('GetBudgetsWithProgress', () {
    test('computes percentage from the budget-scoped spend', () async {
      final budget = makeBudget(
        id: 'budget-1',
        name: 'Overall Budget',
        amount: 500.0,
        startDate: periodStart,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([budget]));
      stubSpendByBudget({'budget-1': 200.0});

      final result = await getBudgetsWithProgress();

      expect(result.isRight(), true);
      result.fold((_) => fail('Should not return failure'), (progressList) {
        expect(progressList.length, 1);
        final progress = progressList.first;
        expect(progress.spentAmount, 200.0);
        expect(progress.percentage, 40.0);
        expect(progress.isOverBudget, false);
        expect(progress.budgetAmount, 500.0);
        expect(progress.effectiveAmount, 500.0);
      });
    });

    test(
      'two budgets in the same period report their own distinct spend',
      () async {
        final food = makeBudget(
          id: 'budget-food',
          name: 'Food',
          amount: 400.0,
          startDate: periodStart,
        );
        final travel = makeBudget(
          id: 'budget-travel',
          name: 'Travel',
          amount: 1000.0,
          startDate: periodStart,
        );

        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([food, travel]));
        stubSpendByBudget({'budget-food': 300.0, 'budget-travel': 100.0});

        final result = await getBudgetsWithProgress();

        result.fold((_) => fail('Should not return failure'), (progressList) {
          final byId = {for (final p in progressList) p.budgetId: p};
          expect(byId['budget-food']!.spentAmount, 300.0);
          expect(byId['budget-food']!.percentage, 75.0);
          expect(byId['budget-travel']!.spentAmount, 100.0);
          expect(byId['budget-travel']!.percentage, 10.0);
        });
      },
    );

    test('over-budget detection works with scoped spend', () async {
      final budget = makeBudget(
        id: 'budget-4',
        amount: 200.0,
        startDate: periodStart,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([budget]));
      stubSpendByBudget({'budget-4': 250.0});

      final result = await getBudgetsWithProgress();

      result.fold((_) => fail('Should not return failure'), (progressList) {
        final progress = progressList.first;
        expect(progress.percentage, 125.0);
        expect(progress.isOverBudget, true);
      });
    });

    test('disabled budgets are excluded and not queried', () async {
      final disabled = makeBudget(
        id: 'budget-disabled',
        amount: 500.0,
        startDate: periodStart,
        isEnabled: false,
      );

      when(
        () => mockBudgetRepository.getBudgets(),
      ).thenAnswer((_) async => Right([disabled]));

      final result = await getBudgetsWithProgress();

      result.fold((_) => fail('Should not return failure'), (progressList) {
        expect(progressList.isEmpty, true);
      });

      verifyNever(() => mockRecordRepository.getSpendingForBudgets(any()));
    });

    test('reads every budget\'s spend in a single call', () async {
      when(() => mockBudgetRepository.getBudgets()).thenAnswer(
        (_) async => Right([
          makeBudget(id: 'a', amount: 100, startDate: periodStart),
          makeBudget(id: 'b', amount: 100, startDate: periodStart),
          makeBudget(id: 'c', amount: 100, startDate: periodStart),
        ]),
      );
      stubSpendByBudget({'a': 10, 'b': 20, 'c': 30});

      await getBudgetsWithProgress();

      verify(() => mockRecordRepository.getSpendingForBudgets(any())).called(1);
    });

    group('rollover', () {
      final june15 = Clock.fixed(DateTime(2026, 6, 15));
      final june = DateTime(2026, 6, 1);

      Future<BudgetProgress> progressFor(
        Budget budget, {
        required double current,
        double previous = 0,
      }) async {
        when(
          () => mockBudgetRepository.getBudgets(),
        ).thenAnswer((_) async => Right([budget]));
        when(
          () => mockRecordRepository.getSpendingForBudgets(any()),
        ).thenAnswer((invocation) async {
          final periods =
              invocation.positionalArguments[0]
                  as Map<String, ({DateTime start, DateTime end})>;

          return Right({
            for (final MapEntry(:key, :value) in periods.entries)
              key: value.start == june ? current : previous,
          });
        });
        final result = await withClock(june15, () => getBudgetsWithProgress());

        return result.getOrElse(() => []).single;
      }

      List<Map<String, ({DateTime start, DateTime end})>> queriedPeriods() =>
          verify(
            () => mockRecordRepository.getSpendingForBudgets(captureAny()),
          ).captured.cast<Map<String, ({DateTime start, DateTime end})>>();

      Budget rolloverBudget({DateTime? startDate}) => makeBudget(
        id: 'b',
        amount: 500,
        startDate: startDate ?? DateTime(2026, 1, 1),
        rolloverEnabled: true,
      );

      test('unspent money from the previous period carries over', () async {
        final progress = await progressFor(
          rolloverBudget(),
          current: 300,
          previous: 350,
        );

        expect(progress.rolloverAmount, 150);
        expect(progress.effectiveAmount, 650);
        expect(progress.percentage, closeTo(300 / 650 * 100, 0.001));
      });

      test('overspending never lowers the next period', () async {
        final progress = await progressFor(
          rolloverBudget(),
          current: 100,
          previous: 650,
        );

        expect(progress.rolloverAmount, 0);
        expect(progress.effectiveAmount, 500);
      });

      test('a budget that started this period has nothing to carry', () async {
        final progress = await progressFor(
          rolloverBudget(startDate: DateTime(2026, 6, 1)),
          current: 100,
        );

        expect(progress.rolloverAmount, 0);
        expect(queriedPeriods(), hasLength(1));
      });

      test('with rollover off only the current period is read', () async {
        final progress = await progressFor(
          makeBudget(id: 'b', amount: 500, startDate: DateTime(2026, 1, 1)),
          current: 100,
        );

        expect(queriedPeriods(), hasLength(1));
        expect(progress.effectiveAmount, 500);
      });

      test('the previous period is the one before the current', () async {
        await progressFor(rolloverBudget(), current: 0);

        final [current, previous] = queriedPeriods();
        expect(current['b']?.start, DateTime(2026, 6, 1));
        expect(previous['b']?.start, DateTime(2026, 5, 1));
        expect(previous['b']?.end, DateTime(2026, 6, 1));
      });
    });
  });
}
