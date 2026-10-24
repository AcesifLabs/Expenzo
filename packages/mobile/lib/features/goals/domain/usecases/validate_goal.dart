import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../entities/goal.dart';

/// A localized validation failure for the goal screens.
Failure goalInputFailure(String message) =>
    CacheFailure(message: message, errorCode: FailureCodes.userMessage);

/// The first problem with [goal], or null when it can be saved.
Failure? validateGoal(Goal goal) {
  final errors = t.goals.errors;
  final amounts = [goal.targetAmount, goal.savedAmount];
  final monthly = goal.monthlyContribution;
  if (monthly != null) amounts.add(monthly);

  if (goal.name.trim().isEmpty) return goalInputFailure(errors.nameRequired);
  if (goal.targetAmount <= 0) return goalInputFailure(errors.targetPositive);
  if (goal.savedAmount < 0 || (monthly != null && monthly < 0)) {
    return goalInputFailure(errors.amountPositive);
  }
  if (amounts.any((a) => a > AppConstants.maxAmount)) {
    return goalInputFailure(errors.amountTooLarge);
  }

  return null;
}
