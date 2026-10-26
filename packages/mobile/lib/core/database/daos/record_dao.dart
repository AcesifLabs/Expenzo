import 'dart:math';

import 'package:expense_tracker/core/utils/money.dart';
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

  Future<List<Record>> getExpensesByDateRange(DateTime start, DateTime end) {
    return (select(records)
          ..where(
            (t) =>
                t.date.isBetweenValues(start, end) &
                t.recordType.equals(RecordType.expense.dbValue),
          )
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

  Future<Set<String>> insertRecordsBatch(
    List<RecordsCompanion> companions,
  ) async {
    return transaction(() async {
      final taken = await _existingIds(companions.map(_idOf).toList());
      final fresh = companions.where((c) => !taken.contains(_idOf(c))).toList();
      await batch(
        (b) => b.insertAll(records, fresh, mode: InsertMode.insertOrIgnore),
      );

      return _existingIds(fresh.map(_idOf).toList());
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

  Future<Map<String, int>> getCategoryRecordCounts() async {
    final count = records.id.count();
    final query = selectOnly(records)
      ..addColumns([records.categoryId, count])
      ..where(records.categoryId.isNotNull())
      ..groupBy([records.categoryId]);
    final rows = await query.get();

    final counts = <String, int>{};
    for (final row in rows) {
      final categoryId = row.read(records.categoryId);
      if (categoryId == null) continue;
      counts[categoryId] = row.read(count) ?? 0;
    }

    return counts;
  }

  Future<List<({String id, String budgetId})>> getBudgetLinks() async {
    final query = selectOnly(records)
      ..addColumns([records.id, records.budgetId])
      ..where(records.budgetId.isNotNull());
    final rows = await query.get();

    final links = <({String id, String budgetId})>[];
    for (final row in rows) {
      final id = row.read(records.id);
      final budgetId = row.read(records.budgetId);
      if (id == null || budgetId == null) continue;
      links.add((id: id, budgetId: budgetId));
    }

    return links;
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

  Future<Map<String, List<double>>> getAmountsBySourceIds(
    List<String> sourceIds,
  ) async {
    if (sourceIds.isEmpty) return {};

    var match = records.sourceId.isIn(sourceIds);
    for (final id in sourceIds) {
      match =
          match |
          (records.sourceId.isBiggerOrEqualValue('$id#') &
              records.sourceId.isSmallerThanValue('$id\$'));
    }
    final query = selectOnly(records)
      ..addColumns([records.sourceId, records.amount])
      ..where(match);
    final amounts = <String, List<double>>{};
    for (final row in await query.get()) {
      final sourceId = row.read(records.sourceId);
      final amount = row.read(records.amount);
      if (sourceId == null || amount == null) continue;
      (amounts[sourceId.split('#').first] ??= []).add(amount.abs());
    }

    return amounts;
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
  ) => _expenseTotal(
    records.categoryId.equals(categoryId) &
        records.date.isBetweenValues(start, end),
  );

  Future<double> getTotalSpending(DateTime start, DateTime end) =>
      _expenseTotal(records.date.isBetweenValues(start, end));

  Future<Map<String, double>> getSpendingForBudgets(
    Map<String, ({DateTime start, DateTime end})> periods,
  ) async {
    if (periods.isEmpty) return const {};

    final starts = periods.values.map((p) => p.start);
    final ends = periods.values.map((p) => p.end);
    final earliest = starts.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = ends.reduce((a, b) => a.isAfter(b) ? a : b);

    final query = selectOnly(records)
      ..addColumns([records.budgetId, records.date, records.amount])
      ..where(
        records.budgetId.isIn(periods.keys) &
            records.date.isBiggerOrEqualValue(earliest) &
            records.date.isSmallerThanValue(latest) &
            records.recordType.equals(RecordType.expense.dbValue),
      );

    final sums = {for (final id in periods.keys) id: 0.0};
    for (final row in await query.get()) {
      final budgetId = row.read(records.budgetId);
      final date = row.read(records.date);
      final period = periods[budgetId];
      if (budgetId == null || date == null || period == null) continue;

      if (date.isBefore(period.start) || !date.isBefore(period.end)) continue;
      sums[budgetId] = sums[budgetId]! + (row.read(records.amount) ?? 0);
    }

    return sums.map((id, sum) => MapEntry(id, sum.abs()));
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

  Future<List<Record>> getFilteredRecords(RecordFilter filter) =>
      _filteredQuery(filter).get();

  Stream<List<Record>> watchFilteredRecords(RecordFilter filter) =>
      _filteredQuery(filter).watch();

  Future<List<({String? categoryId, double total})>> getCategoryBreakdown(
    DateTime start,
    DateTime end,
  ) async {
    final total = records.amount.abs().sum();
    final query = selectOnly(records)
      ..addColumns([records.categoryId, total])
      ..where(
        records.date.isBetweenValues(start, end) &
            records.recordType.equals(RecordType.expense.dbValue),
      )
      ..groupBy([records.categoryId]);

    return [
      for (final row in await query.get())
        (
          categoryId: row.read(records.categoryId),
          total: row.read(total) ?? 0.0,
        ),
    ];
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

  Future<double> _expenseTotal(Expression<bool> filter) async {
    final total = records.amount.abs().sum();
    final row =
        await (selectOnly(records)
              ..addColumns([total])
              ..where(
                filter & records.recordType.equals(RecordType.expense.dbValue),
              ))
            .getSingle();

    return roundMoney(row.read(total) ?? 0);
  }

  static String _idOf(RecordsCompanion row) => row.id.value;

  Future<Set<String>> _existingIds(List<String> ids) async {
    const chunk = 500;
    final found = <String>{};
    for (var i = 0; i < ids.length; i += chunk) {
      final part = ids.sublist(i, min(i + chunk, ids.length));
      final query = selectOnly(records)
        ..addColumns([records.id])
        ..where(records.id.isIn(part));
      found.addAll(
        (await query.get()).map((row) => row.read(records.id)).nonNulls,
      );
    }

    return found;
  }

  SimpleSelectStatement<$RecordsTable, Record> _filteredQuery(
    RecordFilter filter,
  ) {
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

    return q;
  }
}
