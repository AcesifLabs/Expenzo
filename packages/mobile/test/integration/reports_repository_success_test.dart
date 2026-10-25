import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';

void main() {
  late AppDatabase db;
  late RecordDao records;
  late ReportsRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    records = RecordDao(db);
    repository = ReportsRepositoryImpl(
      recordDao: records,
      categoryDao: CategoryDao(db),
    );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat-food',
            name: 'Food',
            color: const Value('#F8BBD0'),
          ),
        );
  });

  tearDown(() => db.close());

  Future<void> spend(String id, double amount, DateTime date, {String? cat}) =>
      records.insertRecord(
        RecordsCompanion.insert(
          id: id,
          amount: -amount,
          description: id,
          date: date,
          recordType: 'OUT',
          categoryId: Value(cat),
        ),
      );

  test('the trend sums each day and fills days without spending', () async {
    await spend('a', 100, DateTime(2026, 10, 1, 9));
    await spend('b', 50, DateTime(2026, 10, 1, 18));
    await spend('c', 30, DateTime(2026, 10, 3, 12));

    final result = await repository.getSpendingTrend(
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 4),
      granularity: Granularity.daily,
    );

    final trend = result.getOrElse(() => fail('expected a trend'));
    expect(trend.map((d) => d.date.day), [1, 2, 3, 4]);
    expect(trend.map((d) => d.amount), [150, 0, 30, 0]);
  });

  test('weekly buckets start on the first day of week', () async {
    WeekStart.current.value = FirstDayOfWeek.saturday;
    addTearDown(() => WeekStart.current.value = FirstDayOfWeek.monday);
    // Saturday 2026-10-03 and the Friday after share a week; the next
    // Saturday starts a new one.
    await spend('a', 100, DateTime(2026, 10, 3, 9));
    await spend('b', 50, DateTime(2026, 10, 9, 18));
    await spend('c', 30, DateTime(2026, 10, 10, 12));

    final result = await repository.getSpendingTrend(
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 12),
      granularity: Granularity.weekly,
    );

    final trend = result.getOrElse(() => fail('expected a trend'));
    // Oct 1 is a Thursday, so the first bucket starts Saturday Sep 26.
    expect(trend.map((d) => d.date), [
      DateTime(2026, 9, 26),
      DateTime(2026, 10, 3),
      DateTime(2026, 10, 10),
    ]);
    expect(trend.map((d) => d.amount), [0, 150, 30]);
  });

  test('the breakdown carries each category color', () async {
    await spend('a', 75, DateTime(2026, 10, 2), cat: 'cat-food');
    await spend('b', 25, DateTime(2026, 10, 2));

    final result = await repository.getCategoryBreakdown(
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 31),
    );

    final byName = {
      for (final c in result.getOrElse(() => fail('expected a breakdown')))
        c.categoryName: c,
    };
    expect(byName['Food']?.colorHex, '#F8BBD0');
    expect(byName['Food']?.amount, 75);
    expect(byName['Uncategorized']?.colorHex, isNull);
  });

  group('income is not spending', () {
    Future<void> earn(String id, double amount, DateTime date) =>
        records.insertRecord(
          RecordsCompanion.insert(
            id: id,
            amount: amount,
            description: id,
            date: date,
            recordType: 'IN',
            categoryId: const Value('cat-salary'),
          ),
        );

    setUp(() async {
      await spend('lunch', 200, DateTime(2026, 10, 2, 13), cat: 'cat-food');
      await earn('salary', 5000, DateTime(2026, 10, 1, 9));
    });

    test('total spent counts expenses only', () async {
      final result = await repository.getSpendingInsights(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
      );
      final insights = result.getOrElse(() => throw StateError('failed'));

      expect(insights.totalSpent, 200);
      expect(insights.totalTransactionCount, 1);
      expect(insights.highestDayAmount, 200);
    });

    test('the category breakdown leaves income categories out', () async {
      final result = await repository.getCategoryBreakdown(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
      );
      final breakdown = result.getOrElse(() => throw StateError('failed'));

      expect(breakdown.map((c) => c.categoryId), ['cat-food']);
      expect(breakdown.single.amount, 200);
    });
  });
}
