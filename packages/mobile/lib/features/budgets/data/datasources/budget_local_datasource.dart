import 'package:drift/drift.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import '../../domain/entities/budget.dart' as domain;

abstract class BudgetLocalDatasource {
  Future<List<domain.Budget>> getBudgets();
  Future<domain.Budget?> getBudgetById(String id);
  Future<void> createBudget(domain.Budget budget);
  Future<void> updateBudget(domain.Budget budget);

  Future<List<Record>> deleteBudget(String id);
  Stream<List<domain.Budget>> watchBudgets();

  /// Writes a whole Budget Plan save in one transaction. Returns the
  /// records unlinked from the deleted budgets.
  Future<List<Record>> applyPlanChanges({
    required List<String> deleteIds,
    required List<domain.Budget> updates,
    required List<domain.Budget> creates,
  });
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
        name: Value(budget.name),
        amount: Value(roundMoney(budget.amount)),
        period: Value(budget.period.name),
        startDate: Value(budget.startDate),
        rolloverEnabled: Value(budget.rolloverEnabled),
        rolloverAmount: Value(roundMoney(budget.rolloverAmount)),
        isEnabled: Value(budget.isEnabled),
        groupId: Value(budget.groupId),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateBudget(domain.Budget budget) async {
    final now = DateTime.now().toUtc();
    final id = budget.id;
    if (id == null) return;
    await budgetDao.updateBudget(
      BudgetsCompanion(
        id: Value(id),
        name: Value(budget.name),
        amount: Value(roundMoney(budget.amount)),
        period: Value(budget.period.name),
        startDate: Value(budget.startDate),
        rolloverEnabled: Value(budget.rolloverEnabled),
        rolloverAmount: Value(roundMoney(budget.rolloverAmount)),
        isEnabled: Value(budget.isEnabled),
        groupId: Value(budget.groupId),
        createdAt: Value(budget.startDate),
        updatedAt: Value(now),
      ),
    );
  }

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

  @override
  Future<List<Record>> applyPlanChanges({
    required List<String> deleteIds,
    required List<domain.Budget> updates,
    required List<domain.Budget> creates,
  }) {
    return budgetDao.transaction(() async {
      final unlinked = <Record>[];
      for (final id in deleteIds) {
        unlinked.addAll(await budgetDao.deleteBudgetAndUnlinkRecords(id));
      }
      for (final budget in updates) {
        await updateBudget(budget);
      }
      for (final budget in creates) {
        await createBudget(budget);
      }

      return unlinked;
    });
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
      groupId: b.groupId,
    );
  }

  BudgetPeriod _parsePeriod(String period) {
    for (final p in BudgetPeriod.values) {
      if (p.name == period) return p;
    }

    return BudgetPeriod.monthly;
  }
}
