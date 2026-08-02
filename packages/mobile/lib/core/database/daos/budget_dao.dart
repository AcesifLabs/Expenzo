import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';
import '../tables/records_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets, Records])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<List<Budget>> getAllBudgets() {
    return select(budgets).get();
  }

  Stream<List<Budget>> watchAllBudgets() {
    return select(budgets).watch();
  }

  Future<Budget?> getBudgetById(String id) {
    final query = select(budgets)..where((b) => b.id.equals(id));

    return query.getSingleOrNull();
  }

  Future<void> insertBudget(BudgetsCompanion budget) async {
    await into(budgets).insert(budget);
  }

  Future<void> updateBudget(BudgetsCompanion budget) async {
    await update(budgets).replace(budget);
  }

  Future<void> deleteBudget(String id) async {
    await (delete(budgets)..where((b) => b.id.equals(id))).go();
  }

  /// Deletes the budget and unlinks any records pointing at it (sets their
  /// budget_id to null), all in one transaction. Returns the affected records
  /// (already unlinked) so callers can enqueue them for sync.
  Future<List<Record>> deleteBudgetAndUnlinkRecords(String id) async {
    return transaction(() async {
      final affectedIds =
          await (selectOnly(records)
                ..addColumns([records.id])
                ..where(records.budgetId.equals(id)))
              .get()
              .then(
                (rows) => rows
                    .map((r) => r.read(records.id))
                    .whereType<String>()
                    .toList(),
              );

      final now = DateTime.now().toUtc();
      await (update(records)..where((r) => r.budgetId.equals(id))).write(
        RecordsCompanion(budgetId: const Value(null), updatedAt: Value(now)),
      );

      await (delete(budgets)..where((b) => b.id.equals(id))).go();

      if (affectedIds.isEmpty) return <Record>[];

      return (select(records)..where((r) => r.id.isIn(affectedIds))).get();
    });
  }
}
