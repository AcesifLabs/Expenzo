import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/recurring_transaction.dart';
import '../helpers/next_occurrence.dart';
import '../repositories/recurring_repository.dart';

class ProcessRecurring {
  final RecurringRepository repository;

  ProcessRecurring(this.repository);

  Future<Either<Failure, List<RecurringTransaction>>> call({
    bool onlyIncluded = false,
  }) async {
    try {
      final dueRecurringResult = await repository.getDueRecurring();

      return dueRecurringResult.fold(
        (failure) => Left(failure),
        (due) => _processDueRecurring(
          onlyIncluded ? due.where((r) => r.autoCreateExpense).toList() : due,
        ),
      );
    } on CacheException catch (e) {
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
    final now = DateTime.now();

    for (final recurring in dueRecurring) {
      final result = _catchUpRecurring(recurring, now);
      processed.addAll(result.processed);
      updates.add(result.updated);
    }

    final updateResult = await repository.updateRecurringBatch(updates);

    return updateResult.fold(
      (failure) => Left(failure),
      (_) => Right(processed),
    );
  }

  _CatchUpResult _catchUpRecurring(
    RecurringTransaction recurring,
    DateTime now,
  ) {
    var current = recurring.nextOccurrence;
    final processed = <RecurringTransaction>[];
    var count = 0;

    while (!current.isAfter(now) && count < kMaxCatchUpOccurrences) {
      final endDate = recurring.endDate;
      if (endDate != null && current.isAfter(endDate)) {
        return _CatchUpResult(
          processed: processed,
          updated: recurring.copyWith(nextOccurrence: current, isActive: false),
        );
      }

      processed.add(recurring.copyWith(nextOccurrence: current));

      current = calculateNextOccurrence(
        current,
        recurring.frequency,

        dayOfMonth: recurring.dayOfMonth ?? recurring.startDate.day,
      );
      count++;
    }

    final endDate = recurring.endDate;
    final isPastEnd = endDate != null && current.isAfter(endDate);

    return _CatchUpResult(
      processed: processed,
      updated: recurring.copyWith(
        nextOccurrence: current,
        isActive: !isPastEnd,
      ),
    );
  }
}

class _CatchUpResult {
  final List<RecurringTransaction> processed;
  final RecurringTransaction updated;

  const _CatchUpResult({required this.processed, required this.updated});
}
