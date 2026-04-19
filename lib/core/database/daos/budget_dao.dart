import 'package:drift/drift.dart';
import '../../../../features/budgets/domain/entities/budget.dart' as domain;
import '../app_database.dart';

class BudgetDao {
  final AppDatabase db;

  BudgetDao(this.db);

  Future<List<domain.Budget>> getAllBudgets() async {
    final budgets = await db.select(db.budgets).get();
    return budgets.map(_mapToEntity).toList();
  }

  Stream<List<domain.Budget>> watchAllBudgets() {
    return db
        .select(db.budgets)
        .watch()
        .map((budgets) => budgets.map(_mapToEntity).toList());
  }

  Future<domain.Budget?> getBudgetById(String id) async {
    final query = db.select(db.budgets)..where((b) => b.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _mapToEntity(result) : null;
  }

  Future<void> insertBudget(BudgetsCompanion budget) async {
    await db.into(db.budgets).insert(budget);
  }

  Future<void> updateBudget(BudgetsCompanion budget) async {
    await db.update(db.budgets).replace(budget);
  }

  Future<void> deleteBudget(String id) async {
    await (db.delete(db.budgets)..where((b) => b.id.equals(id))).go();
  }

  domain.Budget _mapToEntity(Budget b) {
    return domain.Budget(
      id: b.id,
      categoryId: b.categoryId,
      amount: b.amount,
      period: _parsePeriod(b.period),
      startDate: b.startDate,
      rolloverEnabled: b.rolloverEnabled,
      rolloverAmount: b.rolloverAmount,
      isEnabled: b.isEnabled,
    );
  }

  domain.BudgetPeriod _parsePeriod(String period) {
    switch (period) {
      case 'weekly':
        return domain.BudgetPeriod.weekly;
      case 'monthly':
        return domain.BudgetPeriod.monthly;
      case 'yearly':
        return domain.BudgetPeriod.yearly;
      default:
        return domain.BudgetPeriod.monthly;
    }
  }
}
