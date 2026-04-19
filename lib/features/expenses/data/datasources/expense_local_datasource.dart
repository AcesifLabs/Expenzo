import 'package:drift/drift.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/database/app_database.dart' hide Category, Expense;
import '../../../../core/database/daos/expense_dao.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_source.dart';
import '../../domain/repositories/expense_repository.dart';

abstract class ExpenseLocalDatasource {
  Future<List<Expense>> getExpenses({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  });
  Future<Expense?> getExpenseById(int id);
  Future<Expense> addExpense(Expense expense);
  Future<Expense> updateExpense(Expense expense);
  Future<void> deleteExpense(int id);
  Stream<List<Expense>> watchExpenses();
  Future<bool> expenseExistsBySourceId(String sourceId);
}

class ExpenseLocalDatasourceImpl implements ExpenseLocalDatasource {
  final ExpenseDao expenseDao;

  ExpenseLocalDatasourceImpl({required this.expenseDao});

  @override
  Future<List<Expense>> getExpenses({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    try {
      if (dateRange != null) {
        final expenses = await expenseDao.getExpensesByDateRange(
          dateRange.start,
          dateRange.end,
        );
        return expenses.map(_mapToEntity).toList();
      } else if (categoryId != null) {
        final expenses = await expenseDao.getExpensesByCategory(categoryId);
        return expenses.map(_mapToEntity).toList();
      } else {
        final expenses = await expenseDao.getAllExpenses(
          limit: limit,
          offset: offset,
        );
        return expenses.map(_mapToEntity).toList();
      }
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Expense?> getExpenseById(int id) async {
    try {
      final expense = await expenseDao.getExpenseById(id);
      return expense != null ? _mapToEntity(expense) : null;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Expense> addExpense(Expense expense) async {
    try {
      final now = DateTime.now().toUtc();
      final companion = ExpensesCompanion(
        amount: Value(expense.amount),
        description: Value(expense.description),
        date: Value(expense.date),
        categoryId: Value(expense.categoryId),
        source: Value(expense.source.name),
        sourceId: Value(expense.sourceId),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      final id = await expenseDao.insertExpense(companion);
      return expense.copyWith(id: id, createdAt: now, updatedAt: now);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    try {
      final now = DateTime.now().toUtc();
      final companion = ExpensesCompanion(
        id: Value(expense.id!),
        amount: Value(expense.amount),
        description: Value(expense.description),
        date: Value(expense.date),
        categoryId: Value(expense.categoryId),
        source: Value(expense.source.name),
        sourceId: Value(expense.sourceId),
        createdAt: Value(expense.createdAt),
        updatedAt: Value(now),
      );
      await expenseDao.updateExpense(companion);
      return expense.copyWith(updatedAt: now);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      await expenseDao.deleteExpense(id);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return expenseDao.watchExpenses().map(
      (expenses) => expenses.map(_mapToEntity).toList(),
    );
  }

  @override
  Future<bool> expenseExistsBySourceId(String sourceId) async {
    try {
      return await expenseDao.existsBySourceId(sourceId);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  Expense _mapToEntity(dynamic e) {
    return Expense(
      id: e.id,
      amount: e.amount,
      description: e.description,
      date: e.date,
      categoryId: e.categoryId,
      source: ExpenseSource.values.firstWhere(
        (s) => s.name == e.source,
        orElse: () => ExpenseSource.manual,
      ),
      sourceId: e.sourceId,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
