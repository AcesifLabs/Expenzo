class BudgetsRoutes {
  static const String root = '/';
  static const String newBudget = '/budgets/new';
  static const String budgetDetails = '/budgets/:id';
  static const String editBudget = '/budgets/:id/edit';

  static String detailsPath(String id) => '/budgets/$id';
  static String editPath(String id) => '/budgets/$id/edit';
}
