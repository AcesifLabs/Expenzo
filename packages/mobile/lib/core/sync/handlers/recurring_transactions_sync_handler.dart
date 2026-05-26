import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';

class RecurringTransactionsSyncHandler
    extends
        SyncTableHandler<$RecurringTransactionsTable, RecurringTransaction> {
  @override
  String get tableName => 'recurring_transactions';
  @override
  TableInfo<$RecurringTransactionsTable, RecurringTransaction> tableRef(
    AppDatabase db,
  ) => db.recurringTransactions;
  @override
  Map<String, dynamic> toSyncPayload(RecurringTransaction row) => {
    'id': row.id,
    'description': row.description,
    'amount': row.amount,
    'categoryId': row.categoryId,
    'frequency': row.frequency,
    'startDate': row.startDate.toUtc().toIso8601String(),
    'endDate': row.endDate?.toUtc().toIso8601String(),
    'nextOccurrence': row.nextOccurrence.toUtc().toIso8601String(),
    'isActive': row.isActive,
    'autoCreateExpense': row.autoCreateExpense,
    'dayOfMonth': row.dayOfMonth,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<RecurringTransaction> fromSyncPayload(
    String id,
    Map<String, dynamic> data,
  ) => RecurringTransactionsCompanion.insert(
    id: id,
    description: data['description'] ?? '',
    amount: double.parse(data['amount'].toString()),
    categoryId: data['categoryId'] != null
        ? Value(data['categoryId'])
        : const Value.absent(),
    frequency: data['frequency'] ?? 'monthly',
    startDate: DateTime.parse(data['startDate']).toLocal(),
    endDate: data['endDate'] != null
        ? Value(DateTime.parse(data['endDate']).toLocal())
        : const Value.absent(),
    nextOccurrence: DateTime.parse(data['nextOccurrence']).toLocal(),
    isActive: data['isActive'] != null
        ? Value(data['isActive'])
        : const Value.absent(),
    autoCreateExpense: data['autoCreateExpense'] != null
        ? Value(data['autoCreateExpense'])
        : const Value.absent(),
    dayOfMonth: data['dayOfMonth'] != null
        ? Value(int.parse(data['dayOfMonth'].toString()))
        : const Value.absent(),
    createdAt: data['createdAt'] != null
        ? Value(DateTime.parse(data['createdAt']).toLocal())
        : const Value.absent(),
    updatedAt: data['updatedAt'] != null
        ? Value(DateTime.parse(data['updatedAt']).toLocal())
        : const Value.absent(),
  );
  @override
  Future<void> deleteById(AppDatabase db, String id) async => await (db.delete(
    db.recurringTransactions,
  )..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final count = countAll();
    final query = db.selectOnly(db.recurringTransactions)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  @override
  Future<List<RecurringTransaction>> fetchAll(AppDatabase db) =>
      db.select(db.recurringTransactions).get();
}
