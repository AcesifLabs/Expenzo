import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/budget_dao.dart';
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
    return budgetDao.getAllBudgets();
  }

  @override
  Future<domain.Budget?> getBudgetById(String id) async {
    return budgetDao.getBudgetById(id);
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
    return budgetDao.watchAllBudgets();
  }
}
