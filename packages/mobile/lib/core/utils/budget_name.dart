import 'package:expense_tracker/core/constants/app_constants.dart';

/// True for names that stand in for a missing one: empty, whitespace only
/// or [AppConstants.defaultBudgetName].
bool isPlaceholderBudgetName(String name) =>
    name.trim().isEmpty || name == AppConstants.defaultBudgetName;
