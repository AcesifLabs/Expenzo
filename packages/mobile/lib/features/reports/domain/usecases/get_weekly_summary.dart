import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import '../entities/weekly_summary.dart';

/// Spending from the start of this week to [now], against the same span one
/// week earlier, so a late summary still compares equal spans.
class GetWeeklySummary {
  final RecordRepository repository;

  GetWeeklySummary(this.repository);

  Future<Either<Failure, WeeklySummary>> call({
    required DateTime now,
    int? firstWeekday,
  }) async {
    final weekStart = startOfWeek(now, firstWeekday: firstWeekday);
    final thisWeek = await repository.getTotalSpending(weekStart, now);
    final lastWeek = await repository.getTotalSpending(
      _weekEarlier(weekStart),
      _weekEarlier(now),
    );

    return thisWeek.fold(
      Left.new,
      (thisTotal) => lastWeek.fold(
        Left.new,
        (lastTotal) => Right(
          WeeklySummary(
            thisWeekTotal: thisTotal,
            lastWeekTotal: lastTotal,
            weekStart: weekStart,
          ),
        ),
      ),
    );
  }

  static DateTime _weekEarlier(DateTime date) => DateTime(
    date.year,
    date.month,
    date.day - 7,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}
