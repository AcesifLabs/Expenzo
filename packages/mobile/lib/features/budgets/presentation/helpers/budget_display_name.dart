import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/budget_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// [name] as shown to the user: a budget without a real name reads
/// "Unnamed budget" in the current app language. The stored value stays the
/// sync placeholder [AppConstants.defaultBudgetName].
String budgetDisplayName(String name) =>
    isPlaceholderBudgetName(name) ? t.budgets.unnamed : name;
