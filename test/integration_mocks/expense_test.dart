import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_source.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/add_expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/delete_expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  group('Expense Use Case Tests', () {
    late MockExpenseRepository mockRepository;
    late GetExpenses getExpensesUseCase;
    late AddExpense addExpenseUseCase;
    late UpdateExpense updateExpenseUseCase;
    late DeleteExpense deleteExpenseUseCase;

    final now = DateTime.now();
    final testExpense = Expense(
      id: 1,
      amount: 100.50,
      description: 'Lunch at restaurant',
      date: now,
      categoryId: 1,
      source: ExpenseSource.manual,
      sourceId: null,
      createdAt: now,
      updatedAt: now,
    );

    final testExpenses = [
      testExpense,
      Expense(
        id: 2,
        amount: 50.00,
        description: 'Bus fare',
        date: now,
        categoryId: 2,
        source: ExpenseSource.manual,
        sourceId: null,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setUpAll(() {
      registerFallbackValue(testExpense);
      registerFallbackValue(DateTime.now());
    });

    setUp(() {
      mockRepository = MockExpenseRepository();
      getExpensesUseCase = GetExpenses(mockRepository);
      addExpenseUseCase = AddExpense(mockRepository);
      updateExpenseUseCase = UpdateExpense(mockRepository);
      deleteExpenseUseCase = DeleteExpense(mockRepository);
    });

    test('getExpenses returns list of expenses', () async {
      when(
        () => mockRepository.getExpenses(
          dateRange: any(named: 'dateRange'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(testExpenses));

      final result = await getExpensesUseCase(GetExpensesParams());

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (expenses) {
        expect(expenses.length, 2);
        expect(expenses.first.amount, 100.50);
      });
    });

    test('addExpense adds and returns expense', () async {
      when(
        () => mockRepository.addExpense(any()),
      ).thenAnswer((_) async => Right(testExpense));

      final result = await addExpenseUseCase(testExpense);

      expect(result.isRight(), true);
      verify(() => mockRepository.addExpense(testExpense)).called(1);
    });

    test('updateExpense updates and returns expense', () async {
      when(
        () => mockRepository.updateExpense(any()),
      ).thenAnswer((_) async => Right(testExpense));

      final result = await updateExpenseUseCase(testExpense);

      expect(result.isRight(), true);
      verify(() => mockRepository.updateExpense(testExpense)).called(1);
    });

    test('deleteExpense deletes successfully', () async {
      when(
        () => mockRepository.deleteExpense(any()),
      ).thenAnswer((_) async => const Right(unit));

      await deleteExpenseUseCase(1);

      verify(() => mockRepository.deleteExpense(1)).called(1);
    });

    test('getExpenseById returns expense', () async {
      when(
        () => mockRepository.getExpenseById(any()),
      ).thenAnswer((_) async => Right(testExpense));

      final result = await mockRepository.getExpenseById(1);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (expense) {
        expect(expense, testExpense);
        expect(expense.id, 1);
      });
    });

    test('expenseExistsBySourceId returns false', () async {
      when(
        () => mockRepository.expenseExistsBySourceId(any()),
      ).thenAnswer((_) async => const Right(false));

      final result = await mockRepository.expenseExistsBySourceId('sms_123');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (exists) => expect(exists, false),
      );
    });
  });

  group('Expense Entity Tests', () {
    test('should create expense with required fields', () {
      final now = DateTime.now();
      final expense = Expense(
        amount: 100.50,
        description: 'Test expense',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.amount, 100.50);
      expect(expense.description, 'Test expense');
      expect(expense.source, ExpenseSource.manual);
      expect(expense.categoryId, null);
      expect(expense.sourceId, null);
    });

    test('should create expense with all fields', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 1,
        amount: 50.00,
        description: 'Bus fare',
        date: now,
        categoryId: 2,
        source: ExpenseSource.sms,
        sourceId: 'sms_123',
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.id, 1);
      expect(expense.amount, 50.00);
      expect(expense.description, 'Bus fare');
      expect(expense.categoryId, 2);
      expect(expense.source, ExpenseSource.sms);
      expect(expense.sourceId, 'sms_123');
    });

    test('should detect expense from scan', () {
      final now = DateTime.now();
      final manualExpense = Expense(
        amount: 100,
        description: 'Manual',
        date: now,
        source: ExpenseSource.manual,
        createdAt: now,
        updatedAt: now,
      );
      final smsExpense = Expense(
        amount: 100,
        description: 'SMS',
        date: now,
        source: ExpenseSource.sms,
        createdAt: now,
        updatedAt: now,
      );

      expect(manualExpense.isFromScan, false);
      expect(smsExpense.isFromScan, true);
    });

    test('should allow negative amount', () {
      final now = DateTime.now();
      final expense = Expense(
        amount: -50.00,
        description: 'Refund',
        date: now,
        source: ExpenseSource.manual,
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.amount, -50.00);
    });

    test('should allow future date for planned expenses', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 7));
      final expense = Expense(
        amount: 100,
        description: 'Planned expense',
        date: futureDate,
        source: ExpenseSource.manual,
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.date.isAfter(now), true);
    });

    test('should support unlimited description length', () {
      final now = DateTime.now();
      final longDescription = 'A' * 10000;
      final expense = Expense(
        amount: 100,
        description: longDescription,
        date: now,
        source: ExpenseSource.manual,
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.description.length, 10000);
    });

    test('should copy expense with updated fields', () {
      final now = DateTime.now();
      final original = Expense(
        id: 1,
        amount: 100,
        description: 'Original',
        date: now,
        source: ExpenseSource.manual,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(amount: 200, description: 'Updated');

      expect(updated.id, 1);
      expect(updated.amount, 200);
      expect(updated.description, 'Updated');
    });
  });

  group('ExpenseSource Tests', () {
    test('should have correct display names', () {
      expect(ExpenseSource.manual.displayName, 'Manual');
      expect(ExpenseSource.sms.displayName, 'SMS');
      expect(ExpenseSource.email.displayName, 'Email');
      expect(ExpenseSource.recurring.displayName, 'Recurring');
    });

    test('should have correct icons', () {
      expect(ExpenseSource.manual.icon, '✏️');
      expect(ExpenseSource.sms.icon, '💬');
      expect(ExpenseSource.email.icon, '📧');
      expect(ExpenseSource.recurring.icon, '🔄');
    });
  });

  group('DateTimeRange Tests', () {
    test('should create date range with start and end', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);

      final range = DateTimeRange(start: start, end: end);

      expect(range.start, start);
      expect(range.end, end);
    });
  });
}
