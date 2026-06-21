import 'package:drift/drift.dart';
import '../../constants/record_type.dart';
import '../../constants/source_types.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

class RecordsSyncHandler extends SyncTableHandler<$RecordsTable, Record> {
  @override
  String get tableName => 'records';
  @override
  TableInfo<$RecordsTable, Record> tableRef(AppDatabase db) => db.records;
  @override
  Map<String, dynamic> toSyncPayload(Record row) => {
    'id': row.id,
    'amount': row.amount,
    'description': row.description,
    'date': row.date.toUtc().toIso8601String(),
    'categoryId': row.categoryId,
    'source': row.source,
    'recordType': row.recordType,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<Record> fromSyncPayload(String id, Map<String, dynamic> data) =>
      RecordsCompanion.insert(
        id: id,
        amount: double.parse(data['amount'].toString()),
        description: data['description'] ?? '',
        date: DateTime.parse(data['date']).toLocal(),
        categoryId: data['categoryId'] != null
            ? Value(data['categoryId'])
            : const Value.absent(),
        source: Value(data['source'] ?? ExpenseSource.manual.name),
        sourceId: data['sourceId'] != null
            ? Value(data['sourceId'])
            : const Value.absent(),
        recordType: data['recordType'] ?? RecordType.expense.dbValue,
        createdAt: data['createdAt'] != null
            ? Value(DateTime.parse(data['createdAt']).toLocal())
            : const Value.absent(),
        updatedAt: data['updatedAt'] != null
            ? Value(DateTime.parse(data['updatedAt']).toLocal())
            : const Value.absent(),
      );
  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.records)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final count = countAll();
    final query = db.selectOnly(db.records)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  @override
  Future<List<Record>> fetchAll(AppDatabase db) => db.select(db.records).get();
}
