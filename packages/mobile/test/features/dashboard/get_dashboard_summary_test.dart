import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';

class MockRecordRepository extends Mock implements RecordRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockRecordRepository records;
  late MockCategoryRepository categories;
  late GetDashboardSummary useCase;

  final thisMonth = DateRange.thisMonth();
  final savedNow = DateTime.now().toUtc();

  Record buildRecord({
    required String id,
    required DateTime date,
    DateTime? createdAt,
  }) {
    return Record(
      id: id,
      amount: -10,
      description: 'Test $id',
      date: date,
      categoryId: 'cat-1',
      source: ExpenseSource.manual,
      recordType: RecordType.expense,
      createdAt: createdAt ?? date.toUtc(),
      updatedAt: createdAt ?? date.toUtc(),
    );
  }

  /// Receipt-prefilled date in the previous month, but saved just now. Recent
  /// Activity must not surface it — the section is scoped to the dashboard
  /// month so it agrees with the totals shown above it.
  final receiptSave = buildRecord(
    id: 'receipt-1',
    date: thisMonth.startDate.subtract(const Duration(days: 5)),
    createdAt: savedNow,
  );

  final inMonthNewer = buildRecord(
    id: 'in-2',
    date: thisMonth.startDate.add(const Duration(days: 2)),
  );

  final inMonthOlder = buildRecord(id: 'in-1', date: thisMonth.startDate);

  /// Mirrors the repository contract: [getRecords] returns only the records
  /// falling in the requested range, ordered by transaction date descending.
  void stubGetRecords(List<Record> currentMonth) {
    when(
      () => records.getRecords(dateRange: any(named: 'dateRange')),
    ).thenAnswer((invocation) async {
      final range = invocation.namedArguments[#dateRange] as DateTimeRange;
      if (range.start == thisMonth.startDate) {
        return Right(currentMonth);
      }

      return Right([receiptSave]);
    });
  }

  setUpAll(() {
    registerFallbackValue(
      DateTimeRange(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 31)),
    );
  });

  setUp(() {
    records = MockRecordRepository();
    categories = MockCategoryRepository();
    useCase = GetDashboardSummary(
      recordRepository: records,
      categoryRepository: categories,
    );

    when(
      () => categories.getCategories(),
    ).thenAnswer((_) async => const Right([]));
  });

  test('Recent Activity excludes a record dated outside the dashboard month '
      'even when it is the most recent save', () async {
    stubGetRecords([inMonthNewer, inMonthOlder]);

    // Sanity: the receipt was saved after every in-month record, so a
    // save-time-ordered query would have put it first.
    expect(receiptSave.createdAt.isAfter(inMonthNewer.createdAt), isTrue);
    expect(receiptSave.date.isBefore(thisMonth.startDate), isTrue);

    final result = await useCase(thisMonth);

    final summary = result.getOrElse(
      () => throw StateError('expected summary'),
    );
    expect(summary.recentTransactions.map((r) => r.id), ['in-2', 'in-1']);
    expect(summary.totalExpense, 20); // only in-month records count
  });

  test('Recent Activity is capped at 5 records', () async {
    final sixInMonth = List.generate(
      6,
      (i) => buildRecord(
        id: 'in-$i',
        date: thisMonth.startDate.add(Duration(days: 5 - i)),
      ),
    );
    stubGetRecords(sixInMonth);

    final result = await useCase(thisMonth);

    final summary = result.getOrElse(
      () => throw StateError('expected summary'),
    );
    expect(summary.recentTransactions.map((r) => r.id), [
      'in-0',
      'in-1',
      'in-2',
      'in-3',
      'in-4',
    ]);
  });
}
