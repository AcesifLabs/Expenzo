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

  final now = DateTime(2026, 8, 2, 12);
  final thisMonthRange = DateTimeRange(
    start: DateTime(2026, 8, 1),
    end: DateTime(2026, 8, 31, 23, 59, 59),
  );

  /// Receipt-prefilled date outside "this month", but saved just now.
  final receiptSave = Record(
    id: 'receipt-1',
    amount: -42,
    description: 'Coffee shop',
    date: DateTime(2026, 7, 15),
    categoryId: 'cat-1',
    source: ExpenseSource.manual,
    recordType: RecordType.expense,
    createdAt: now.toUtc(),
    updatedAt: now.toUtc(),
  );

  final augustOlder = Record(
    id: 'aug-1',
    amount: -10,
    description: 'Older august',
    date: DateTime(2026, 8, 1),
    categoryId: 'cat-1',
    source: ExpenseSource.manual,
    recordType: RecordType.expense,
    createdAt: now.subtract(const Duration(days: 1)).toUtc(),
    updatedAt: now.subtract(const Duration(days: 1)).toUtc(),
  );

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

  test('Recent Activity includes newest save even when transaction date is '
      'outside the dashboard month range', () async {
    when(
      () => records.getRecords(dateRange: any(named: 'dateRange')),
    ).thenAnswer((invocation) async {
      final range = invocation.namedArguments[#dateRange] as DateTimeRange;
      if (range.start.month == 8) {
        return Right([augustOlder]);
      }
      if (range.start.month == 7) {
        return Right([receiptSave]);
      }

      return const Right([]);
    });

    when(
      () => records.getRecentRecordsByCreatedAt(limit: any(named: 'limit')),
    ).thenAnswer((_) async => Right([receiptSave, augustOlder]));

    // Sanity: month-scoped fetch alone would hide the receipt save.
    expect(receiptSave.date.isBefore(thisMonthRange.start), isTrue);

    final result = await useCase(DateRange.thisMonth());

    final summary = result.getOrElse(
      () => throw StateError('expected summary'),
    );
    expect(summary.recentTransactions.map((r) => r.id), ['receipt-1', 'aug-1']);
    expect(summary.totalExpense, 10); // only August in range
  });
}
