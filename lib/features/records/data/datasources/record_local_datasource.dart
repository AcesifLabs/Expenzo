import 'package:drift/drift.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    hide Category, Record;
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/record.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../../domain/repositories/record_repository.dart';

abstract class RecordLocalDatasource {
  Future<List<Record>> getRecords({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  });
  Future<Record?> getRecordById(int id);
  Future<Record> addRecord(Record record);
  Future<Record> updateRecord(Record record);
  Future<void> deleteRecord(int id);
  Stream<List<Record>> watchRecords({int? limit, int? offset});
  Future<bool> recordExistsBySourceId(String sourceId);
  Future<Set<String>> getExistingSourceIds(List<String> sourceIds);
  Future<void> addRecordsBatch(List<Record> records);
  Future<List<Record>> getRecordsByCategoryAndDateRange(
    int categoryId,
    DateTime start,
    DateTime end,
  );
  Future<double> getCategorySpending(
    int categoryId,
    DateTime start,
    DateTime end,
  );
  Future<double> getTotalSpending(DateTime start, DateTime end);
  Future<List<Record>> getRecordsByDateRangeOnly(DateTime start, DateTime end);
}

class RecordLocalDatasourceImpl implements RecordLocalDatasource {
  final RecordDao recordDao;

  RecordLocalDatasourceImpl({required this.recordDao});

  @override
  Future<List<Record>> getRecords({
    DateTimeRange? dateRange,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    try {
      if (dateRange != null) {
        final records = await recordDao.getRecordsByDateRange(
          dateRange.start,
          dateRange.end,
        );
        return records.map(_mapToEntity).toList();
      } else if (categoryId != null) {
        final records = await recordDao.getRecordsByCategory(categoryId);
        return records.map(_mapToEntity).toList();
      } else {
        final records = await recordDao.getAllRecords(
          limit: limit,
          offset: offset,
        );
        return records.map(_mapToEntity).toList();
      }
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Record?> getRecordById(int id) async {
    try {
      final record = await recordDao.getRecordById(id);
      return record != null ? _mapToEntity(record) : null;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Record> addRecord(Record record) async {
    try {
      final now = DateTime.now().toUtc();
      final companion = RecordsCompanion(
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
      final id = await recordDao.insertRecord(companion);
      return record.copyWith(id: id, createdAt: now, updatedAt: now);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Record> updateRecord(Record record) async {
    try {
      final now = DateTime.now().toUtc();
      final companion = RecordsCompanion(
        id: Value(record.id!),
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
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteRecord(int id) async {
    try {
      await recordDao.deleteRecord(id);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Stream<List<Record>> watchRecords({int? limit, int? offset}) {
    return recordDao
        .watchRecords(limit: limit, offset: offset)
        .map((records) => records.map(_mapToEntity).toList());
  }

  @override
  Future<bool> recordExistsBySourceId(String sourceId) async {
    try {
      return await recordDao.existsBySourceId(sourceId);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Set<String>> getExistingSourceIds(List<String> sourceIds) async {
    try {
      return await recordDao.getExistingSourceIds(sourceIds);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<Record>> getRecordsByCategoryAndDateRange(
    int categoryId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final records = await recordDao.getRecordsByCategoryAndDateRange(
        categoryId,
        start,
        end,
      );
      return records.map(_mapToEntity).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<double> getCategorySpending(
    int categoryId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await recordDao.getCategorySpending(categoryId, start, end);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<double> getTotalSpending(DateTime start, DateTime end) async {
    try {
      return await recordDao.getTotalSpending(start, end);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<Record>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final records = await recordDao.getRecordsByDateRangeOnly(start, end);
      return records.map(_mapToEntity).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> addRecordsBatch(List<Record> records) async {
    try {
      final now = DateTime.now().toUtc();
      final companions = records.map((record) {
        return RecordsCompanion(
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
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  Record _mapToEntity(dynamic e) {
    return Record(
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
