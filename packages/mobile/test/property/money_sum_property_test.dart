import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

void main() {
  late AppDatabase db;

  property('a sum of stored amounts matches the sum in whole cents', () {
    forAll(
      list(everydayCents(), minLength: 1, maxLength: 60),
      maxExamples: propertyTrials,
      setUp: () => db = AppDatabase.forTesting(NativeDatabase.memory()),
      tearDown: () => db.close(),
      (cents) async {
        await db.batch(
          (b) => b.insertAll(db.records, [
            for (final (i, c) in cents.indexed)
              RecordsCompanion.insert(
                id: 'r$i',
                amount: -c / 100,
                description: 'expense $i',
                date: DateTime(2026, 10, 1 + i % 28),
                recordType: 'OUT',
              ),
          ]),
        );

        final total = await RecordDao(
          db,
        ).getTotalSpending(DateTime(2026, 10), DateTime(2026, 11));
        final exact = cents.fold(0, (sum, c) => sum + c) / 100;
        expect(total, closeTo(exact, 0.005));
      },
    );
  });
}
