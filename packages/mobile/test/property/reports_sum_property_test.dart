import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

void main() {
  late AppDatabase db;

  /// Spending in a past range: (cents, day offset, is income).
  final entries = list(
    combine3(everydayCents(), integer(min: 0, max: 400), boolean()),
    maxLength: 40,
  );

  property('the chart buckets add up to the range total', () {
    forAll(
      combine3(
        entries,
        integer(min: 1, max: 400),
        constantFrom(Granularity.values),
      ),
      maxExamples: propertyTrials,
      setUp: () => db = AppDatabase.forTesting(NativeDatabase.memory()),
      tearDown: () => db.close(),
      (v) async {
        final (rows, length, granularity) = v;
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 1 + length, 23, 59, 59);
        await db.batch(
          (b) => b.insertAll(db.records, [
            for (final (i, (cents, offset, income)) in rows.indexed)
              RecordsCompanion.insert(
                id: 'r$i',
                amount: income ? cents / 100 : -cents / 100,
                description: 'row $i',
                date: DateTime(2024, 1, 1 + offset, 12),
                recordType: income ? 'IN' : 'OUT',
              ),
          ]),
        );
        final recordDao = RecordDao(db);
        final reports = ReportsRepositoryImpl(
          recordDao: recordDao,
          categoryDao: CategoryDao(db),
        );

        final trend = (await reports.getSpendingTrend(
          startDate: start,
          endDate: end,
          granularity: granularity,
        )).getOrElse(() => fail('trend failed'));
        final bucketed = trend.fold(0.0, (sum, b) => sum + b.amount);

        expect(
          bucketed,
          closeTo(await recordDao.getTotalSpending(start, end), 0.005),
        );
      },
    );
  });
}
