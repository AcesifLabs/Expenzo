import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import '../../support/factories/record_factory.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockRecordRepository extends Mock implements RecordRepository {}

void main() {
  late MockBudgetRepository budgetRepository;
  late MockRecordRepository recordRepository;
  late GetBudgetTransactions useCase;

  final now = DateTime.now();
  final periodStart = DateTime(now.year, now.month, 1);

  setUp(() {
    budgetRepository = MockBudgetRepository();
    recordRepository = MockRecordRepository();
    useCase = GetBudgetTransactions(
      budgetRepository: budgetRepository,
      recordRepository: recordRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  test(
    'returns only expense records linked to this budget in the current period',
    () async {
      final budget = Budget(
        id: 'b1',
        name: 'Overall',
        amount: 500,
        period: BudgetPeriod.monthly,
        startDate: periodStart,
      );

      when(
        () => budgetRepository.getBudgetById('b1'),
      ).thenAnswer((_) async => Right(budget));

      when(
        () => recordRepository.getRecordsByDateRangeOnly(any(), any()),
      ).thenAnswer(
        (_) async => Right([
          makeRecord(
            id: 'e1',
            recordType: RecordType.expense,
            amount: 40,
            budgetId: 'b1',
          ),
          makeRecord(
            id: 'i1',
            recordType: RecordType.income,
            amount: 100,
            budgetId: 'b1',
          ),
          makeRecord(
            id: 'e2',
            recordType: RecordType.expense,
            amount: 20,
            budgetId: 'b1',
          ),
          // Linked to a different budget -> excluded.
          makeRecord(
            id: 'e3',
            recordType: RecordType.expense,
            amount: 15,
            budgetId: 'b2',
          ),
          // Unlinked expense -> excluded.
          makeRecord(id: 'e4', recordType: RecordType.expense, amount: 5),
        ]),
      );

      final result = await useCase('b1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected success'), (records) {
        expect(records.map((r) => r.id), ['e1', 'e2']);
      });
    },
  );
}
