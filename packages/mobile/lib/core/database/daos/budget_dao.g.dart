part of 'budget_dao.dart';

mixin _$BudgetDaoMixin on DatabaseAccessor<AppDatabase> {
  $BudgetsTable get budgets => attachedDatabase.budgets;
}
