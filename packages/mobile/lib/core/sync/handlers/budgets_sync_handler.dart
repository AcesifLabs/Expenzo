import 'package:drift/drift.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/budget_name.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import '../../database/app_database.dart';
import '../sync_table_registry.dart';
import 'sync_parse_helpers.dart';

class BudgetsSyncHandler extends SyncTableHandler<$BudgetsTable, Budget> {
  /// While true, a pulled default name does not replace a real local one.
  /// The server dropped names until it had a column for them, so its old
  /// rows read [AppConstants.defaultBudgetName] until the one-time name repair succeeds.
  final bool Function() keepLocalNames;

  /// Local names of the budgets in the pull being applied, loaded once by
  /// [beforeApplyingPull]; null outside a pull or once the repair is done.
  Map<String, String>? _localNames;

  @override
  String get tableName => 'budgets';

  BudgetsSyncHandler({bool Function()? keepLocalNames})
    : keepLocalNames = keepLocalNames ?? _never;

  @override
  TableInfo<$BudgetsTable, Budget> tableRef(AppDatabase db) => db.budgets;
  @override
  Map<String, dynamic> toSyncPayload(Budget row) => {
    'id': row.id,
    'name': row.name,
    'amount': row.amount,
    'period': row.period,
    'startDate': row.startDate.toUtc().toIso8601String(),
    'rolloverEnabled': row.rolloverEnabled,
    'rolloverAmount': row.rolloverAmount,
    'isEnabled': row.isEnabled,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };
  @override
  Insertable<Budget> fromSyncPayload(String id, Map<String, dynamic> data) =>
      BudgetsCompanion.insert(
        id: id,
        name: _nameOrDefault(data['name']),
        amount: parseSyncAmount(data['amount']),
        period: parseSyncString(data['period'], BudgetPeriod.monthly.name),
        startDate: parseSyncDate(data['startDate']),
        rolloverEnabled: data['rolloverEnabled'] != null
            ? Value(data['rolloverEnabled'] == true)
            : const Value.absent(),
        rolloverAmount: data['rolloverAmount'] != null
            ? Value(parseSyncAmount(data['rolloverAmount']))
            : const Value.absent(),
        isEnabled: data['isEnabled'] != null
            ? Value(data['isEnabled'] == true)
            : const Value.absent(),
        createdAt: data['createdAt'] != null
            ? Value(parseSyncDate(data['createdAt']))
            : const Value.absent(),
        updatedAt: data['updatedAt'] != null
            ? Value(parseSyncDate(data['updatedAt']))
            : const Value.absent(),
      );

  @override
  Future<void> beforeApplyingPull(AppDatabase db, List<String> ids) async {
    if (!keepLocalNames()) return;
    final rows = await (db.select(
      db.budgets,
    )..where((t) => t.id.isIn(ids))).get();
    _localNames = {for (final row in rows) row.id: row.name};
  }

  @override
  Future<void> afterApplyingPull() {
    _localNames = null;

    return Future.value();
  }

  @override
  Future<Insertable<Budget>> keepLocalValues(
    AppDatabase db,
    String id,
    Insertable<Budget> incoming,
  ) async {
    final companion = incoming as BudgetsCompanion;
    if (companion.name.value != AppConstants.defaultBudgetName) {
      return companion;
    }

    final String? localName;
    if (_localNames case final names?) {
      localName = names[id];
    } else {
      if (!keepLocalNames()) return companion;
      localName = (await (db.select(
        db.budgets,
      )..where((t) => t.id.equals(id))).getSingleOrNull())?.name;
    }
    if (localName == null || isPlaceholderBudgetName(localName)) {
      return companion;
    }

    return companion.copyWith(name: Value(localName));
  }

  @override
  Future<void> deleteById(AppDatabase db, String id) async =>
      await (db.delete(db.budgets)..where((t) => t.id.equals(id))).go();
  @override
  Future<int> countRows(AppDatabase db) async {
    final c = countAll();
    final query = db.selectOnly(db.budgets)..addColumns([c]);
    final result = await query.getSingle();

    return result.read(c) ?? 0;
  }

  @override
  Future<List<Budget>> fetchAll(AppDatabase db) => db.select(db.budgets).get();

  static String _nameOrDefault(Object? raw) {
    final name = raw?.toString() ?? '';

    return name.trim().isEmpty ? AppConstants.defaultBudgetName : name;
  }

  static bool _never() => false;
}
