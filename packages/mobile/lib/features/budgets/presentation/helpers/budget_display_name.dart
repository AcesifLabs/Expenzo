import 'package:expense_tracker/core/utils/budget_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

String budgetDisplayName(String name) =>
    isPlaceholderBudgetName(name) ? t.budgets.unnamed : name;
