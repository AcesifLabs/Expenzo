import 'package:drift/drift.dart';
import '../../constants/record_type.dart';
import '../../constants/source_types.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';
import 'sync_parse_helpers.dart';

class RecordsSyncHandler extends SyncTableHandler<$RecordsTable, Record> {
  /// While true, a pulled record without a budget link does not clear the
  /// local link. The server dropped links until SAAP-76; they are trusted
  /// once the one-time link repair is done. Defaults to true (unlike
  /// `BudgetsSyncHandler.keepLocalNames`): until the repair is known to be
  /// done, dropping a link loses data the server may never have had.
  final bool Function() keepLocalBudgetLinks;

  @override
  String get tableName => 'records';

  RecordsSyncHandler({bool Function()? keepLocalBudgetLinks})
    : keepLocalBudgetLinks = keepLocalBudgetLinks ?? _always;

  @override
  TableInfo<$RecordsTable, Record> tableRef(AppDatabase db) => db.records;
  @override
  Map<String, dynamic> toSyncPayload(Record row) => {
    'id': row.id,
    'amount': row.amount,
    'description': row.description,
    'date': row.date.toUtc().toIso8601String(),
    'categoryId': row.categoryId,
    'budgetId': row.budgetId,
    'source': row.source,
    'recordType': row.recordType,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<Record> fromSyncPayload(
    String id,
    Map<String, dynamic> data,
  ) => RecordsCompanion.insert(
    id: id,
    amount: parseSyncAmount(data['amount']),
    description: parseSyncString(data['description']),
    date: parseSyncDate(data['date']),
    categoryId: data['categoryId'] != null
        ? Value(data['categoryId'].toString())
        : const Value.absent(),
    budgetId: _pulledBudgetId(data),
    source: Value(parseSyncString(data['source'], ExpenseSource.manual.name)),
    sourceId: data['sourceId'] != null
        ? Value(data['sourceId'].toString())
        : const Value.absent(),
    recordType: parseSyncString(data['recordType'], RecordType.expense.dbValue),
    createdAt: data['createdAt'] != null
        ? Value(parseSyncDate(data['createdAt']))
        : const Value.absent(),
    updatedAt: data['updatedAt'] != null
        ? Value(parseSyncDate(data['updatedAt']))
        : const Value.absent(),
  );
  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.records)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.records)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<Record>> fetchAll(AppDatabase db) => db.select(db.records).get();

  static bool _always() => true;

  /// A pulled link always replaces the local one. A pulled null clears it only
  /// when [keepLocalBudgetLinks] is false; a missing key never changes it.
  Value<String?> _pulledBudgetId(Map<String, dynamic> data) {
    final budgetId = data['budgetId'];
    if (budgetId != null) return Value(budgetId.toString());
    if (data.containsKey('budgetId') && !keepLocalBudgetLinks()) {
      return const Value(null);
    }

    return const Value.absent();
  }
}
