import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/records_table.dart';

part 'record_dao.g.dart';

@DriftAccessor(tables: [Records])
class RecordDao extends DatabaseAccessor<AppDatabase> with _$RecordDaoMixin {
  RecordDao(super.db);

  Stream<List<Record>> watchRecords({int? limit, int? offset}) {
    var query = select(records)..orderBy([(t) => OrderingTerm.desc(t.date)]);
    if (limit != null) query = query..limit(limit, offset: offset);
    return query.watch();
  }

  Future<List<Record>> getAllRecords({int? limit, int? offset}) {
    final query = select(records)..orderBy([(t) => OrderingTerm.desc(t.date)]);
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  Future<Record?> getRecordById(String id) {
    return (select(records)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Record>> getRecordsByDateRange(DateTime start, DateTime end) {
    return (select(records)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<Record>> getRecordsByCategory(String categoryId) {
    return (select(records)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertRecord(RecordsCompanion record) {
    return into(records).insert(record);
  }

  /// Bulk insert with transaction for efficiency on low-end storage.
  Future<void> insertRecordsBatch(List<RecordsCompanion> companions) async {
    await transaction(() async {
      for (final companion in companions) {
        await into(records).insert(companion);
      }
    });
  }

  Future<bool> updateRecord(RecordsCompanion record) {
    return update(
      records,
    ).replace(record.copyWith(updatedAt: Value(DateTime.now().toUtc())));
  }

  Future<int> deleteRecord(String id) {
    return (delete(records)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getRecordCountByCategory(String categoryId) async {
    final count = countAll();
    final query = selectOnly(records)
      ..addColumns([count])
      ..where(records.categoryId.equals(categoryId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<bool> existsBySourceId(String sourceId) async {
    final count = countAll();
    final query = selectOnly(records)
      ..addColumns([count])
      ..where(records.sourceId.equals(sourceId));
    final result = await query.getSingle();
    final cnt = result.read(count) ?? 0;
    return cnt > 0;
  }

  /// Batch lookup: returns the set of sourceIds that already exist in the DB.
  /// Uses a single SQL query with IN clause instead of N individual queries.
  Future<Set<String>> getExistingSourceIds(List<String> sourceIds) async {
    if (sourceIds.isEmpty) return {};

    final query = selectOnly(records)
      ..addColumns([records.sourceId])
      ..where(records.sourceId.isIn(sourceIds));

    final results = await query.get();
    return results
        .map((row) => row.read(records.sourceId))
        .whereType<String>()
        .toSet();
  }

  Future<List<Record>> getRecordsByCategoryAndDateRange(
    String categoryId,
    DateTime start,
    DateTime end,
  ) {
    return (select(records)
          ..where(
            (t) =>
                t.categoryId.equals(categoryId) &
                t.date.isBetweenValues(start, end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<double> getCategorySpending(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    final items =
        await (select(records)..where(
              (t) =>
                  t.categoryId.equals(categoryId) &
                  t.date.isBetweenValues(start, end) &
                  t.recordType.equals('OUT'),
            ))
            .get();
    double total = 0;
    for (final item in items) {
      total += item.amount.abs();
    }
    return total;
  }

  Future<double> getTotalSpending(DateTime start, DateTime end) async {
    final items =
        await (select(records)..where(
              (t) =>
                  t.date.isBetweenValues(start, end) &
                  t.recordType.equals('OUT'),
            ))
            .get();
    double total = 0;
    for (final item in items) {
      total += item.amount.abs();
    }
    return total;
  }

  Future<List<Record>> getRecordsByDateRangeOnly(
    DateTime start,
    DateTime end,
  ) async {
    return (select(records)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TypedResult>> getCategoryBreakdown(DateTime start, DateTime end) {
    final amountSum = records.amount.sum();
    final query = selectOnly(records)
      ..addColumns([records.categoryId, amountSum])
      ..where(records.date.isBetweenValues(start, end))
      ..groupBy([records.categoryId]);
    return query.get();
  }

  Future<List<TypedResult>> getSpendingTrend(DateTime start, DateTime end) {
    final amountSum = records.amount.sum();
    final query = selectOnly(records)
      ..addColumns([records.date, amountSum])
      ..where(records.date.isBetweenValues(start, end))
      ..groupBy([records.date]);
    return query.get();
  }
}
