import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    show PendingRecurringData;
import '../entities/recurring_transaction.dart';

/// Repository for managing recurring transactions.
abstract class RecurringRepository {
  /// Retrieves all recurring transactions.
  ///
  /// Returns [Right(List<RecurringTransaction>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<RecurringTransaction>>> getRecurringList();

  /// Retrieves a recurring transaction by its [id].
  ///
  /// Returns [Right(RecurringTransaction)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, RecurringTransaction>> getRecurringById(String id);

  /// Creates a new [recurring] transaction.
  ///
  /// Returns [Right(RecurringTransaction)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, RecurringTransaction>> createRecurring(
    RecurringTransaction recurring,
  );

  /// Updates an existing [recurring] transaction.
  ///
  /// Returns [Right(RecurringTransaction)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, RecurringTransaction>> updateRecurring(
    RecurringTransaction recurring,
  );

  /// Updates a batch of [transactions] in a single operation.
  ///
  /// Returns [Right(unit)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Unit>> updateRecurringBatch(
    List<RecurringTransaction> transactions,
  );

  /// Deletes a recurring transaction by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Unit>> deleteRecurring(String id);

  /// Watches for changes to the recurring list.
  Stream<List<RecurringTransaction>> watchRecurringList();

  /// Retrieves recurring transactions that are due for processing.
  ///
  /// Returns [Right(List<RecurringTransaction>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<RecurringTransaction>>> getDueRecurring();

  /// Watches for pending recurring transactions.
  Stream<List<PendingRecurringData>> watchPendingRecurring();

  /// Removes a pending recurring entry by [id].
  Future<void> removePendingRecurring(String id);
}
