import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class ProcessRecurring {
  final RecurringRepository repository;

  ProcessRecurring(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.

  Future<Either<Failure, List<RecurringTransaction>>> call() async {
    try {
      final dueRecurringResult = await repository.getDueRecurring();

      return dueRecurringResult.fold(
        (failure) => Left(failure),
        _processDueRecurring,
      );
    } on CacheException catch (e, s) {
      return Left(e.toFailure());
    }
  }

  Future<Either<Failure, List<RecurringTransaction>>> _processDueRecurring(
    List<RecurringTransaction> dueRecurring,
  ) async {
    if (dueRecurring.isEmpty) {
      return const Right([]);
    }

    final processed = <RecurringTransaction>[];
    final updates = <RecurringTransaction>[];

    for (final recurring in dueRecurring) {
      if (recurring.autoCreateExpense) {
        processed.add(recurring);
      }

      final nextDate = _calculateNextOccurrence(
        recurring.nextOccurrence,
        recurring.frequency,
      );

      updates.add(recurring.copyWith(nextOccurrence: nextDate));
    }

    final updateResult = await repository.updateRecurringBatch(updates);

    return updateResult.fold(
      (failure) => Left(failure),
      (_) => Right(processed),
    );
  }

  DateTime _calculateNextOccurrence(
    DateTime current,
    RecurringFrequency frequency,
  ) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return current.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return current.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(current.year, current.month + 1, current.day);
      case RecurringFrequency.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }
}
