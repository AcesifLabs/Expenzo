import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
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
}
