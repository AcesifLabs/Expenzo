import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDatasource localDatasource;

  ExpenseRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<CacheFailure, List<Expense>>> getExpenses({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    try {
      final expenses = await localDatasource.getExpenses(
        dateRange: dateRange,
        categoryId: categoryId,
        limit: limit,
        offset: offset,
      );
      return Right(expenses);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Expense>> getExpenseById(int id) async {
    try {
      final expense = await localDatasource.getExpenseById(id);
      if (expense == null) {
        return const Left(CacheFailure(message: 'Expense not found'));
      }
      return Right(expense);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Expense>> addExpense(Expense expense) async {
    try {
      final added = await localDatasource.addExpense(expense);
      return Right(added);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Expense>> updateExpense(Expense expense) async {
    try {
      final updated = await localDatasource.updateExpense(expense);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteExpense(int id) async {
    try {
      await localDatasource.deleteExpense(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<Expense>> watchExpenses({int? limit, int? offset}) {
    return localDatasource.watchExpenses(limit: limit, offset: offset);
  }

  @override
  Future<Either<CacheFailure, bool>> expenseExistsBySourceId(
    String sourceId,
  ) async {
    try {
      final exists = await localDatasource.expenseExistsBySourceId(sourceId);
      return Right(exists);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Set<String>>> getExistingSourceIds(
    List<String> sourceIds,
  ) async {
    try {
      final existing = await localDatasource.getExistingSourceIds(sourceIds);
      return Right(existing);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, void>> addExpensesBatch(
    List<Expense> expenses,
  ) async {
    try {
      await localDatasource.addExpensesBatch(expenses);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }
}
