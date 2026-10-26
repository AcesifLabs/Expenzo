import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/reports/domain/entities/weekly_summary.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_weekly_summary.dart';

class _MockRecordRepository extends Mock implements RecordRepository {}

void main() {
  late _MockRecordRepository repository;
  late GetWeeklySummary getWeeklySummary;

  final now = DateTime(2026, 10, 18, 20);
  final weekStart = DateTime(2026, 10, 12);

  setUp(() {
    repository = _MockRecordRepository();
    getWeeklySummary = GetWeeklySummary(repository);
  });

  void totals({required double thisWeek, required double lastWeek}) {
    when(
      () => repository.getTotalSpending(weekStart, now),
    ).thenAnswer((_) async => Right(thisWeek));
    when(
      () => repository.getTotalSpending(
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 11, 20),
      ),
    ).thenAnswer((_) async => Right(lastWeek));
  }

  test('totals and percent change come from the repository', () async {
    totals(thisWeek: 1500, lastWeek: 1000);

    final result = await getWeeklySummary(now: now);
    final summary = result.getOrElse(() => throw StateError('Left'));

    expect(
      summary,
      WeeklySummary(
        thisWeekTotal: 1500,
        lastWeekTotal: 1000,
        weekStart: weekStart,
      ),
    );
    expect(summary.changePercent, 50);
  });

  test('both weeks use spans of equal length', () async {
    totals(thisWeek: 10, lastWeek: 10);

    await getWeeklySummary(now: now);

    verify(() => repository.getTotalSpending(weekStart, now)).called(1);
    verify(
      () => repository.getTotalSpending(
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 11, 20),
      ),
    ).called(1);
  });

  test('no spending last week gives no change', () async {
    totals(thisWeek: 200, lastWeek: 0);

    final result = await getWeeklySummary(now: now);

    expect(
      result.getOrElse(() => throw StateError('Left')).changePercent,
      isNull,
    );
  });

  test('a repository failure returns Left', () async {
    when(
      () => repository.getTotalSpending(any(), any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));

    final result = await getWeeklySummary(now: now);

    expect(result.isLeft(), isTrue);
  });

  test('a Saturday start sums from the last Saturday', () async {
    final friday = DateTime(2026, 10, 16, 20);
    when(
      () => repository.getTotalSpending(DateTime(2026, 10, 10), friday),
    ).thenAnswer((_) async => const Right(300));
    when(
      () => repository.getTotalSpending(
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 9, 20),
      ),
    ).thenAnswer((_) async => const Right(200));

    final result = await getWeeklySummary(
      now: friday,
      firstWeekday: DateTime.saturday,
    );
    final summary = result.getOrElse(() => throw StateError('Left'));

    expect(summary.weekStart, DateTime(2026, 10, 10));
    expect(summary.thisWeekTotal, 300);
    expect(summary.lastWeekTotal, 200);
  });
}
