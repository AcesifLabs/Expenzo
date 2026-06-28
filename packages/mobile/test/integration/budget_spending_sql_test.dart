import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;
  late RecordDao recordDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    recordDao = RecordDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('RecordDao spending filters', () {
    test('getTotalSpending should only include OUT records', () async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);

      await recordDao.insertRecord(
        RecordsCompanion.insert(
          id: '1',
          amount: -100.0,
          description: 'Lunch',
          date: now,
          recordType: 'OUT',
        ),
      );

      await recordDao.insertRecord(
        RecordsCompanion.insert(
          id: '2',
          amount: 500.0,
          description: 'Salary',
          date: now,
          recordType: 'IN',
        ),
      );

      final spending = await recordDao.getTotalSpending(start, end);

      expect(spending, 100.0);
    });

    test(
      'getCategorySpending should only include OUT records for specific category',
      () async {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        const categoryId = 'cat1';

        await recordDao.insertRecord(
          RecordsCompanion.insert(
            id: '1',
            amount: -50.0,
            description: 'Coffee',
            date: now,
            categoryId: const Value(categoryId),
            recordType: 'OUT',
          ),
        );

        await recordDao.insertRecord(
          RecordsCompanion.insert(
            id: '2',
            amount: 20.0,
            description: 'Refund',
            date: now,
            categoryId: const Value(categoryId),
            recordType: 'IN',
          ),
        );

        await recordDao.insertRecord(
          RecordsCompanion.insert(
            id: '3',
            amount: -200.0,
            description: 'Rent',
            date: now,
            categoryId: const Value('cat2'),
            recordType: 'OUT',
          ),
        );

        final spending = await recordDao.getCategorySpending(
          categoryId,
          start,
          end,
        );

        expect(spending, 50.0);
      },
    );
  });
}
