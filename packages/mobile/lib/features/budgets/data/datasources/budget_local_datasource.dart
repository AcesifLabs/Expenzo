import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import '../../domain/entities/budget.dart' as domain;

abstract class BudgetLocalDatasource {
  Future<List<domain.Budget>> getBudgets();
  Future<domain.Budget?> getBudgetById(String id);
  Future<void> createBudget(domain.Budget budget);
  Future<void> updateBudget(domain.Budget budget);
  Future<void> deleteBudget(String id);
  Stream<List<domain.Budget>> watchBudgets();
}

class BudgetLocalDatasourceImpl implements BudgetLocalDatasource {
  final BudgetDao budgetDao;

  BudgetLocalDatasourceImpl({required this.budgetDao});

  @override
  Future<List<domain.Budget>> getBudgets() async {
    final budgets = await budgetDao.getAllBudgets();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Future<domain.Budget?> getBudgetById(String id) async {
    final budget = await budgetDao.getBudgetById(id);
    return budget != null ? _mapToEntity(budget) : null;
  }

  @override
  Future<void> createBudget(domain.Budget budget) async {
    final now = DateTime.now().toUtc();
    await budgetDao.insertBudget(
      BudgetsCompanion(
        id: Value(
          budget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        categoryId: Value(budget.categoryId),
        amount: Value(budget.amount),
        period: Value(budget.period.name),
        startDate: Value(budget.startDate),
        rolloverEnabled: Value(budget.rolloverEnabled),
        rolloverAmount: Value(budget.rolloverAmount),
        isEnabled: Value(budget.isEnabled),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateBudget(domain.Budget budget) async {
    final now = DateTime.now().toUtc();
    await budgetDao.updateBudget(
      BudgetsCompanion(
        id: Value(budget.id!),
        categoryId: Value(budget.categoryId),
        amount: Value(budget.amount),
        period: Value(budget.period.name),
        startDate: Value(budget.startDate),
        rolloverEnabled: Value(budget.rolloverEnabled),
        rolloverAmount: Value(budget.rolloverAmount),
        isEnabled: Value(budget.isEnabled),
        createdAt: Value(budget.startDate), // Keep original
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    await budgetDao.deleteBudget(id);
  }

  @override
  Stream<List<domain.Budget>> watchBudgets() {
    return budgetDao.watchAllBudgets().map(
      (budgets) => budgets.map(_mapToEntity).toList(),
    );
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
    for (final p in domain.BudgetPeriod.values) {
      if (p.name == period) return p;
    }
    return domain.BudgetPeriod.monthly;
  }
}
