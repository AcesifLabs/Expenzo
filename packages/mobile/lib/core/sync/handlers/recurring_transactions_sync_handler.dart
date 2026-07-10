import 'package:drift/drift.dart';
import '../../constants/transaction_frequency.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';
import 'sync_parse_helpers.dart';

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
    description: parseSyncString(data['description']),
    amount: parseSyncAmount(data['amount']),
    categoryId: data['categoryId'] != null
        ? Value(data['categoryId'].toString())
        : const Value.absent(),
    frequency: parseSyncString(
      data['frequency'],
      TransactionFrequency.monthly.name,
    ),
    startDate: parseSyncDate(data['startDate']),
    endDate: data['endDate'] != null
        ? Value(parseSyncDate(data['endDate']))
        : const Value.absent(),
    nextOccurrence: parseSyncDate(data['nextOccurrence']),
    isActive: data['isActive'] != null
        ? Value(data['isActive'] == true)
        : const Value.absent(),
    autoCreateExpense: data['autoCreateExpense'] != null
        ? Value(data['autoCreateExpense'] == true)
        : const Value.absent(),
    dayOfMonth: data['dayOfMonth'] != null
        ? Value(int.tryParse(data['dayOfMonth'].toString()) ?? 0)
        : const Value.absent(),
    createdAt: data['createdAt'] != null
        ? Value(parseSyncDate(data['createdAt']))
        : const Value.absent(),
    updatedAt: data['updatedAt'] != null
        ? Value(parseSyncDate(data['updatedAt']))
        : const Value.absent(),
  );
  @override
  Future<void> deleteById(AppDatabase db, String id) async => await (db.delete(
    db.recurringTransactions,
  )..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.recurringTransactions)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<RecurringTransaction>> fetchAll(AppDatabase db) =>
      db.select(db.recurringTransactions).get();
}
