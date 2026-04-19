import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../entities/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class ProcessRecurring {
  final RecurringRepository repository;

  ProcessRecurring(this.repository);

  Future<Either<Failure, List<RecurringTransaction>>> call() async {
    try {
      final dueRecurringResult = await repository.getDueRecurring();

      return dueRecurringResult.fold((failure) => Left(failure), (
        dueRecurring,
      ) async {
        final processed = <RecurringTransaction>[];

        for (final recurring in dueRecurring) {
          if (recurring.autoCreateExpense) {
            processed.add(recurring);
          }

          final nextDate = _calculateNextOccurrence(
            recurring.nextOccurrence,
            recurring.frequency,
          );

          final updated = recurring.copyWith(nextOccurrence: nextDate);

          await repository.updateRecurring(updated);
        }

        return Right(processed);
      });
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
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
