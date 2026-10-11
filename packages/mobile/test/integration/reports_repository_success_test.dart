import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
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
}
