import 'package:drift/drift.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import '../../domain/entities/budget.dart' as domain;

abstract class BudgetLocalDatasource {
  /// Throws: [CacheException] if a database error occurs.
  Future<List<domain.Budget>> getBudgets();
  Future<domain.Budget?> getBudgetById(String id);
  Future<void> createBudget(domain.Budget budget);
  Future<void> updateBudget(domain.Budget budget);

  /// Deletes the budget and unlinks its records. Returns the unlinked record
  /// rows so the repository can enqueue them for sync.
  Future<List<Record>> deleteBudget(String id);
  Stream<List<domain.Budget>> watchBudgets();
}

class BudgetLocalDatasourceImpl implements BudgetLocalDatasource {
  final BudgetDao budgetDao;

  BudgetLocalDatasourceImpl({required this.budgetDao});

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<domain.Budget>> getBudgets() async {
    final budgets = await budgetDao.getAllBudgets();

    return budgets.map(_mapToEntity).toList();
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<domain.Budget?> getBudgetById(String id) async {
    final budget = await budgetDao.getBudgetById(id);

    return budget != null ? _mapToEntity(budget) : null;
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> createBudget(domain.Budget budget) async {
    final now = DateTime.now().toUtc();
    await budgetDao.insertBudget(
      BudgetsCompanion(
        id: Value(
          budget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        name: Value(budget.name),
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

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> updateBudget(domain.Budget budget) async {
    final now = DateTime.now().toUtc();
    final id = budget.id;
    if (id == null) return;
    await budgetDao.updateBudget(
      BudgetsCompanion(
        id: Value(id),
        name: Value(budget.name),
        amount: Value(budget.amount),
        period: Value(budget.period.name),
        startDate: Value(budget.startDate),
        rolloverEnabled: Value(budget.rolloverEnabled),
        rolloverAmount: Value(budget.rolloverAmount),
        isEnabled: Value(budget.isEnabled),
        createdAt: Value(budget.startDate),
        updatedAt: Value(now),
      ),
    );
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<Record>> deleteBudget(String id) async {
    return budgetDao.deleteBudgetAndUnlinkRecords(id);
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
      name: b.name,
      amount: b.amount,
      period: _parsePeriod(b.period),
      startDate: b.startDate,
      rolloverEnabled: b.rolloverEnabled,
      rolloverAmount: b.rolloverAmount,
      isEnabled: b.isEnabled,
    );
  }

  BudgetPeriod _parsePeriod(String period) {
    for (final p in BudgetPeriod.values) {
      if (p.name == period) return p;
    }

    return BudgetPeriod.monthly;
  }
}
