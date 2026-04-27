import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/recurring_local_datasource.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringLocalDatasource localDatasource;

  RecurringRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<RecurringTransaction>>> getRecurringList() async {
    try {
      final recurring = await localDatasource.getRecurringList();
      return Right(recurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, RecurringTransaction>> getRecurringById(
    String id,
  ) async {
    try {
      final recurring = await localDatasource.getRecurringById(id);
      if (recurring == null) {
        return const Left(
          CacheFailure(message: 'Recurring transaction not found'),
        );
      }
      return Right(recurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, RecurringTransaction>> createRecurring(
    RecurringTransaction recurring,
  ) async {
    try {
      await localDatasource.createRecurring(recurring);
      return Right(recurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, RecurringTransaction>> updateRecurring(
    RecurringTransaction recurring,
  ) async {
    try {
      await localDatasource.updateRecurring(recurring);
      return Right(recurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateRecurringBatch(
    List<RecurringTransaction> transactions,
  ) async {
    try {
      await localDatasource.updateRecurringBatch(transactions);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecurring(String id) async {
    try {
      await localDatasource.deleteRecurring(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<RecurringTransaction>> watchRecurringList() {
    return localDatasource.watchRecurringList();
  }

  @override
  Future<Either<Failure, List<RecurringTransaction>>> getDueRecurring() async {
    try {
      final dueRecurring = await localDatasource.getDueRecurring();
      return Right(dueRecurring);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }
}
