import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/recurring_transaction.dart';
import '../helpers/next_occurrence.dart';
import '../repositories/recurring_repository.dart';

class ProcessRecurring {
  final RecurringRepository repository;

  ProcessRecurring(this.repository);

  ///
  /// For each due recurring, advances occurrences until the next one is in the
  /// future (catch-up). Respects [RecurringTransaction.endDate]. Each elapsed
  /// occurrence produces one entry in the returned list.
  ///
  /// With [onlyIncluded] (an automatic run), items whose
  /// [RecurringTransaction.autoCreateExpense] is false are left untouched:
  /// neither returned nor advanced, so a manual run still posts them.
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

  /// Advances [recurring] from its current [nextOccurrence] until the next
  /// occurrence is in the future or exceeds [endDate].
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
        dayOfMonth: recurring.dayOfMonth,
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

/// Result of catch-up processing for a single recurring transaction.
class _CatchUpResult {
  final List<RecurringTransaction> processed;
  final RecurringTransaction updated;

  const _CatchUpResult({required this.processed, required this.updated});
}
