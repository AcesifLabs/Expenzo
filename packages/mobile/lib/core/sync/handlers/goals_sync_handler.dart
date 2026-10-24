import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../sync_table_names.dart';
import '../sync_table_registry.dart';
import 'sync_parse_helpers.dart';

/// Savings goals (ADR 0009). `savedAmount` is last-write-wins like every
/// synced field.
class GoalsSyncHandler extends SyncTableHandler<$GoalsTable, Goal> {
  @override
  String get tableName => SyncTableNames.goals;

  @override
  TableInfo<$GoalsTable, Goal> tableRef(AppDatabase db) => db.goals;
  @override
  Map<String, dynamic> toSyncPayload(Goal row) => {
    'id': row.id,
    'name': row.name,
    'targetAmount': row.targetAmount,
    'savedAmount': row.savedAmount,
    'targetDate': row.targetDate?.toUtc().toIso8601String(),
    'monthlyContribution': row.monthlyContribution,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<Goal> fromSyncPayload(String id, Map<String, dynamic> data) =>
      GoalsCompanion.insert(
        id: id,
        name: parseSyncString(data['name']),
        targetAmount: parseSyncAmount(data['targetAmount']),
        savedAmount: Value(parseSyncAmount(data['savedAmount'])),
        // parseSyncDate(null) returns now, so null must stay null here.
        targetDate: data['targetDate'] != null
            ? Value(parseSyncDate(data['targetDate']))
            : const Value(null),
        monthlyContribution: data['monthlyContribution'] != null
            ? Value(parseSyncAmount(data['monthlyContribution']))
            : const Value(null),
        createdAt: data['createdAt'] != null
            ? Value(parseSyncDate(data['createdAt']))
            : const Value.absent(),
        updatedAt: data['updatedAt'] != null
            ? Value(parseSyncDate(data['updatedAt']))
            : const Value.absent(),
      );

  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.goals)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.goals)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<Goal>> fetchAll(AppDatabase db) => db.select(db.goals).get();
}
