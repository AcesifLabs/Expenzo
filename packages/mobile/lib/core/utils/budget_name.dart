import 'package:expense_tracker/core/constants/app_constants.dart';

bool isPlaceholderBudgetName(String name) =>
    name.trim().isEmpty || name == AppConstants.defaultBudgetName;
