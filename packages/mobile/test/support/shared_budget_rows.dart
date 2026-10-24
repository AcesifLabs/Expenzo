import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';

/// Inserts a budget row, shared into [groupId] when given.
Future<void> insertBudgetRow(AppDatabase db, String id, {String? groupId}) => db
    .into(db.budgets)
    .insert(
      BudgetsCompanion.insert(
        id: id,
        name: id,
        amount: 100,
        period: 'monthly',
        startDate: DateTime(2026),
        groupId: Value(groupId),
      ),
    );

Future<Map<String, String?>> budgetGroupIds(AppDatabase db) async => {
  for (final row in await db.select(db.budgets).get()) row.id: row.groupId,
};
