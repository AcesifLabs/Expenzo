import 'package:drift/drift.dart';
import '../../constants/record_type.dart';
import '../app_database.dart';
import '../tables/records_table.dart';
import '../../../features/records/domain/filters/record_filter.dart';

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
                  t.recordType.equals(RecordType.expense.dbValue),
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
                  t.recordType.equals(RecordType.expense.dbValue),
            ))
            .get();
    double total = 0;
    for (final item in items) {
      total += item.amount.abs();
    }

    return total;
  }

  /// Total expense spend linked to [budgetId] within the half-open range
  /// [start, end). The end bound is exclusive so a record dated exactly at the
  /// next period's start is not double-counted across adjacent periods.
  Future<double> getBudgetSpending(
    String budgetId,
    DateTime start,
    DateTime end,
  ) async {
    final amountSum = records.amount.sum();
    final query = selectOnly(records)
      ..addColumns([amountSum])
      ..where(
        records.budgetId.equals(budgetId) &
            records.date.isBiggerOrEqualValue(start) &
            records.date.isSmallerThanValue(end) &
            records.recordType.equals(RecordType.expense.dbValue),
      );

    final row = await query.getSingleOrNull();

    return (row?.read(amountSum) ?? 0).abs();
  }

  Future<List<Record>> getRecordsByDateRangeOnly(DateTime start, DateTime end) {
    return (select(records)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<Record>> getFilteredRecords(RecordFilter filter) {
    final q = select(records);

    q.where((t) {
      final dateFilter = _buildDateFilter(t, filter.startDate, filter.endDate);
      Expression<bool> where = dateFilter;

      final catIds = filter.categoryIds;
      if (catIds != null && catIds.isNotEmpty) {
        where = where & t.categoryId.isIn(catIds);
      }

      final rt = filter.recordType;
      if (rt != null && rt.isNotEmpty) {
        where = where & t.recordType.equals(rt);
      }

      return where;
    });

    q.orderBy([(t) => OrderingTerm.desc(t.date)]);
    final limit = filter.limit;
    if (limit != null) q.limit(limit, offset: filter.offset);

    return q.get();
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
      ..where(
        records.date.isBetweenValues(start, end) &
            records.recordType.equals(RecordType.expense.dbValue),
      )
      ..groupBy([records.date]);

    return query.get();
  }

  Expression<bool> _buildDateFilter(
    Records t,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null && endDate != null) {
      return t.date.isBetweenValues(startDate, endDate);
    }
    if (startDate != null) return t.date.isBiggerOrEqualValue(startDate);
    if (endDate != null) return t.date.isSmallerOrEqualValue(endDate);

    return const Constant(true);
  }
}
