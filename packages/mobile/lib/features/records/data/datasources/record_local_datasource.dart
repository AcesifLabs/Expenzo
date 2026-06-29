import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/record.dart' as rec;
import "package:expense_tracker/core/constants/source_types.dart";
import '../../domain/repositories/record_repository.dart';
import 'package:flutter/foundation.dart';

abstract class RecordLocalDatasource {
  /// Throws: [CacheException] if a database error occurs.
  Future<List<rec.Record>> getRecords({
    DateTimeRange? dateRange,
    String? categoryId,
    int? limit,
    int? offset,
  });

  /// Throws: [CacheException] if a database error occurs.
  Future<rec.Record?> getRecordById(String id);
  Future<rec.Record> addRecord(rec.Record record);
  Future<rec.Record> updateRecord(rec.Record record);
  Future<void> deleteRecord(String id);
  Stream<List<rec.Record>> watchRecords({int? limit, int? offset});

  /// Throws: [CacheException] if a database error occurs.
  Future<bool> recordExistsBySourceId(String sourceId);
  Future<Set<String>> getExistingSourceIds(List<String> sourceIds);
  Future<void> addRecordsBatch(List<rec.Record> records);
  Future<List<rec.Record>> getRecordsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  );

  /// Throws: [CacheException] if a database error occurs.
  Future<double> getCategorySpending(
    String categoryId,
    DateTime start,
    DateTime end,
  );

  /// Throws: [CacheException] if a database error occurs.
  Future<double> getTotalSpending(DateTime start, DateTime end);
  Future<List<rec.Record>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  );

  /// Throws: [CacheException] if a database error occurs.
  Future<List<rec.Record>> getFilteredRecords(RecordFilter filter);
}

class RecordLocalDatasourceImpl implements RecordLocalDatasource {
  final RecordDao recordDao;

  RecordLocalDatasourceImpl({required this.recordDao});

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<rec.Record>> getRecords({
    DateTimeRange? dateRange,
    String? categoryId,
    int? limit,
    int? offset,
  }) async {
    try {
      if (dateRange != null) {
        final records = await recordDao.getRecordsByDateRange(
          dateRange.start,
          dateRange.end,
        );

        return records.map<rec.Record>((e) => _mapToEntity(e)).toList();
      } else if (categoryId != null) {
        final records = await recordDao.getRecordsByCategory(categoryId);

        return records.map<rec.Record>((e) => _mapToEntity(e)).toList();
      } else {
        final records = await recordDao.getAllRecords(
          limit: limit,
          offset: offset,
        );

        return records.map<rec.Record>((e) => _mapToEntity(e)).toList();
      }
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<rec.Record?> getRecordById(String id) async {
    try {
      final record = await recordDao.getRecordById(id);

      return record != null ? _mapToEntity(record) : null;
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<rec.Record> addRecord(rec.Record record) async {
    try {
      final now = DateTime.now().toUtc();
      final id = record.id ?? const Uuid().v4();
      final companion = db.RecordsCompanion(
        id: Value(id),
        amount: Value(record.amount),
        description: Value(record.description),
        date: Value(record.date),
        categoryId: Value(record.categoryId),
        source: Value(record.source.name),
        sourceId: Value(record.sourceId),
        recordType: Value(record.recordType.dbValue),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      await recordDao.insertRecord(companion);

      return record.copyWith(id: id, createdAt: now, updatedAt: now);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<rec.Record> updateRecord(rec.Record record) async {
    try {
      final now = DateTime.now().toUtc();
      final recordId = record.id;
      if (recordId == null) {
        throw const CacheException(message: 'Record ID is required for update');
      }
      final companion = db.RecordsCompanion(
        id: Value(recordId),
        amount: Value(record.amount),
        description: Value(record.description),
        date: Value(record.date),
        categoryId: Value(record.categoryId),
        source: Value(record.source.name),
        sourceId: Value(record.sourceId),
        recordType: Value(record.recordType.dbValue),
        createdAt: Value(record.createdAt),
        updatedAt: Value(now),
      );
      await recordDao.updateRecord(companion);

      return record.copyWith(updatedAt: now);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> deleteRecord(String id) async {
    try {
      await recordDao.deleteRecord(id);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Stream<List<rec.Record>> watchRecords({int? limit, int? offset}) {
    return recordDao
        .watchRecords(limit: limit, offset: offset)
        .map(
          (records) => records.map<rec.Record>((e) => _mapToEntity(e)).toList(),
        );
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<bool> recordExistsBySourceId(String sourceId) async {
    try {
      return await recordDao.existsBySourceId(sourceId);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<Set<String>> getExistingSourceIds(List<String> sourceIds) async {
    try {
      return await recordDao.getExistingSourceIds(sourceIds);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<rec.Record>> getRecordsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final records = await recordDao.getRecordsByCategoryAndDateRange(
        categoryId,
        start,
        end,
      );

      return records.map<rec.Record>((e) => _mapToEntity(e)).toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<double> getCategorySpending(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await recordDao.getCategorySpending(categoryId, start, end);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<double> getTotalSpending(DateTime start, DateTime end) async {
    try {
      return await recordDao.getTotalSpending(start, end);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<rec.Record>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final records = await recordDao.getRecordsByDateRangeOnly(start, end);

      return records.map<rec.Record>((e) => _mapToEntity(e)).toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> addRecordsBatch(List<rec.Record> records) async {
    try {
      final now = DateTime.now().toUtc();
      final companions = records.map((record) {
        final id = record.id ?? const Uuid().v4();

        return db.RecordsCompanion(
          id: Value(id),
          amount: Value(record.amount),
          description: Value(record.description),
          date: Value(record.date),
          categoryId: Value(record.categoryId),
          source: Value(record.source.name),
          sourceId: Value(record.sourceId),
          recordType: Value(record.recordType.dbValue),
          createdAt: Value(now),
          updatedAt: Value(now),
        );
      }).toList();
      await recordDao.insertRecordsBatch(companions);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<rec.Record>> getFilteredRecords(RecordFilter filter) async {
    try {
      final records = await recordDao.getFilteredRecords(filter);

      return records.map<rec.Record>((e) => _mapToEntity(e)).toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  rec.Record _mapToEntity(db.Record e) {
    return rec.Record(
      id: e.id,
      amount: e.amount,
      description: e.description,
      date: e.date,
      categoryId: e.categoryId,
      source: ExpenseSource.values.firstWhere(
        (s) => s.name == e.source,
        orElse: () => ExpenseSource.manual,
      ),
      sourceId: e.sourceId,
      recordType: RecordType.fromDbValue(e.recordType),
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
