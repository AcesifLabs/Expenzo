import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/process_recurring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/recurring_factory.dart';

class _MockRecurringRepository extends Mock implements RecurringRepository {}

void main() {
  late _MockRecurringRepository repository;
  late ProcessRecurring processRecurring;

  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final excluded = makeRecurring(
    id: 'excluded',
    frequency: RecurringFrequency.daily,
    nextOccurrence: yesterday,
    autoCreateExpense: false,
  );
  final included = makeRecurring(
    id: 'included',
    frequency: RecurringFrequency.daily,
    nextOccurrence: yesterday,
  );

  setUp(() {
    repository = _MockRecurringRepository();
    processRecurring = ProcessRecurring(repository);
    when(
      () => repository.updateRecurringBatch(any()),
    ).thenAnswer((_) async => const Right(unit));
  });

  void dueItems(List<RecurringTransaction> items) {
    when(
      () => repository.getDueRecurring(),
    ).thenAnswer((_) async => Right(items));
  }

  List<RecurringTransaction> savedUpdates() =>
      verify(
            () => repository.updateRecurringBatch(captureAny()),
          ).captured.single
          as List<RecurringTransaction>;

  test('an automatic run skips and does not advance excluded items', () async {
    dueItems([excluded, included]);

    final result = await processRecurring(onlyIncluded: true);

    final posted = result.getOrElse(() => []);
    expect(posted.map((r) => r.id).toSet(), {'included'});
    expect(savedUpdates().map((r) => r.id), ['included']);
  });

  test('an automatic run with only excluded items saves nothing', () async {
    dueItems([excluded]);

    final result = await processRecurring(onlyIncluded: true);

    expect(result.getOrElse(() => throw StateError('Left')), isEmpty);
    verifyNever(() => repository.updateRecurringBatch(any()));
  });

  test('a manual run returns the occurrences of an excluded item', () async {
    dueItems([excluded]);

    final result = await processRecurring();

    final posted = result.getOrElse(() => []);
    expect(posted, isNotEmpty);
    expect(posted.every((r) => r.id == 'excluded'), isTrue);
  });

  test('catch-up returns one entry per elapsed occurrence', () async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day - 3);
    dueItems([
      makeRecurring(frequency: RecurringFrequency.daily, nextOccurrence: start),
    ]);

    final result = await processRecurring();

    // start, start+1, start+2, start+3 (today at midnight) are all due.
    final dates = result.getOrElse(() => []).map((r) => r.nextOccurrence);
    expect(dates, [
      for (var i = 0; i < 4; i++)
        DateTime(start.year, start.month, start.day + i),
    ]);
  });

  test('catch-up stops at the end date and deactivates the item', () async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day - 3);
    dueItems([
      makeRecurring(
        frequency: RecurringFrequency.daily,
        nextOccurrence: start,
        endDate: DateTime(start.year, start.month, start.day + 1),
      ),
    ]);

    final result = await processRecurring();

    expect(result.getOrElse(() => []), hasLength(2));
    expect(savedUpdates().single.isActive, isFalse);
  });

  test('a monthly item saved without a day of month keeps its start day '
      'after a short month', () async {
    dueItems([
      makeRecurring(
        startDate: DateTime(2025, 1, 31),
        nextOccurrence: DateTime(2025, 2, 28),
      ),
    ]);

    final result = await processRecurring();

    final dates = result.getOrElse(() => []).map((r) => r.nextOccurrence);
    expect(dates.take(3), [
      DateTime(2025, 2, 28),
      DateTime(2025, 3, 31),
      DateTime(2025, 4, 30),
    ]);
    for (final date in dates) {
      final lastDay = DateTime(date.year, date.month + 1, 0).day;
      expect(date.day, lastDay < 31 ? lastDay : 31, reason: '$date');
    }
  });
}
