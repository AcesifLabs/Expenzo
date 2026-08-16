import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;
  late RecordDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = RecordDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('RecordDao.getFilteredRecords', () {
    final now = DateTime.now();
    final cat1 = 'cat-1';
    final cat2 = 'cat-2';

    Future<void> insertRecord({
      required String id,
      required double amount,
      required DateTime date,
      String? categoryId,
      required String type,
    }) async {
      await db
          .into(db.records)
          .insert(
            RecordsCompanion.insert(
              id: id,
              amount: amount,
              description: 'Test $id',
              date: date,
              categoryId: Value(categoryId),
              recordType: type,
            ),
          );
    }

    test('should filter by date range', () async {
      await insertRecord(
        id: '1',
        amount: 10,
        date: now.subtract(const Duration(days: 5)),
        type: 'OUT',
      );
      await insertRecord(id: '2', amount: 20, date: now, type: 'OUT');
      await insertRecord(
        id: '3',
        amount: 30,
        date: now.add(const Duration(days: 5)),
        type: 'OUT',
      );

      final results = await dao.getFilteredRecords(
        RecordFilter(
          startDate: now.subtract(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 1)),
        ),
      );

      expect(results.length, 1);
      expect(results.first.id, '2');
    });

    test('should filter by multiple categories', () async {
      await insertRecord(
        id: '1',
        amount: 10,
        date: now,
        categoryId: cat1,
        type: 'OUT',
      );
      await insertRecord(
        id: '2',
        amount: 20,
        date: now,
        categoryId: cat2,
        type: 'OUT',
      );
      await insertRecord(
        id: '3',
        amount: 30,
        date: now,
        categoryId: 'other',
        type: 'OUT',
      );

      final results = await dao.getFilteredRecords(
        RecordFilter(categoryIds: [cat1, cat2]),
      );

      expect(results.length, 2);
      final ids = results.map((e) => e.id).toSet();
      expect(ids.contains('1'), true);
      expect(ids.contains('2'), true);
    });

    test('should filter by record type', () async {
      await insertRecord(id: '1', amount: 10, date: now, type: 'IN');
      await insertRecord(id: '2', amount: 20, date: now, type: 'OUT');

      final results = await dao.getFilteredRecords(
        RecordFilter(recordType: 'IN'),
      );

      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('should combine all filters', () async {
      await insertRecord(
        id: '1',
        amount: 10,
        date: now,
        categoryId: cat1,
        type: 'IN',
      );
      await insertRecord(
        id: '2',
        amount: 20,
        date: now,
        categoryId: cat1,
        type: 'OUT',
      );
      await insertRecord(
        id: '3',
        amount: 30,
        date: now,
        categoryId: 'other',
        type: 'IN',
      );
      await insertRecord(
        id: '4',
        amount: 40,
        date: now.subtract(const Duration(days: 10)),
        categoryId: cat1,
        type: 'IN',
      );

      final results = await dao.getFilteredRecords(
        RecordFilter(
          startDate: now.subtract(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 1)),
          categoryIds: [cat1],
          recordType: 'IN',
        ),
      );

      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('should return all records when no filters provided', () async {
      await insertRecord(id: '1', amount: 10, date: now, type: 'IN');
      await insertRecord(id: '2', amount: 20, date: now, type: 'OUT');

      final results = await dao.getFilteredRecords(const RecordFilter());

      expect(results.length, 2);
    });
  });

  group('RecordDao.getSpendingTrend', () {
    final day = DateTime(2026, 8, 10);

    Future<void> insertRecord({
      required String id,
      required double amount,
      required DateTime date,
      required String type,
    }) async {
      await db
          .into(db.records)
          .insert(
            RecordsCompanion.insert(
              id: id,
              amount: amount,
              description: 'Test $id',
              date: date,
              recordType: type,
            ),
          );
    }

    test('sums expenses only, so income cannot inflate a trend bar', () async {
      await insertRecord(id: 'out-1', amount: 25, date: day, type: 'OUT');
      await insertRecord(id: 'in-1', amount: 100, date: day, type: 'IN');

      final rows = await dao.getSpendingTrend(
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 31, 23, 59, 59),
      );

      expect(rows.length, 1);
      expect(rows.first.read(dao.records.amount.sum()), 25);
    });
  });
}
