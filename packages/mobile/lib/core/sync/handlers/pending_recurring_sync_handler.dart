import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

class PendingRecurringSyncHandler
    extends SyncTableHandler<$PendingRecurringTable, PendingRecurringData> {
  @override
  String get tableName => 'pending_recurring';
  @override
  TableInfo<$PendingRecurringTable, PendingRecurringData> tableRef(
    AppDatabase db,
  ) => db.pendingRecurring;
  @override
  Map<String, dynamic> toSyncPayload(PendingRecurringData row) => {
    'id': row.id,
    'recurringId': row.recurringId,
    'dueDate': row.dueDate.toUtc().toIso8601String(),
    'amount': row.amount,
    'description': row.description,
    'categoryId': row.categoryId,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.createdAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<PendingRecurringData> fromSyncPayload(
    String id,
    Map<String, dynamic> data,
  ) => PendingRecurringCompanion.insert(
    id: id,
    recurringId: data['recurringId'] ?? '',
    dueDate: DateTime.parse(data['dueDate']).toLocal(),
    amount: double.parse(data['amount'].toString()),
    description: data['description'] ?? '',
    categoryId: data['categoryId'] != null
        ? Value(data['categoryId'])
        : const Value.absent(),
    createdAt: data['createdAt'] != null
        ? Value(DateTime.parse(data['createdAt']).toLocal())
        : const Value.absent(),
  );
  @override
  Future<void> deleteById(AppDatabase db, String id) async => await (db.delete(
    db.pendingRecurring,
  )..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.pendingRecurring)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<PendingRecurringData>> fetchAll(AppDatabase db) =>
      db.select(db.pendingRecurring).get();
}
