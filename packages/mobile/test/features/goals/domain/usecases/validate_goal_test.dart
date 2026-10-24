import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/usecases/validate_goal.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

void main() {
  const goal = Goal(
    name: 'Laptop',
    targetAmount: 1999,
    savedAmount: 100,
    monthlyContribution: 300,
  );
  final errors = t.goals.errors;

  String? messageFor(Goal goal) => validateGoal(goal)?.message;

  test('a valid goal passes', () {
    expect(validateGoal(goal), isNull);
  });

  test('no monthly amount is fine', () {
    expect(validateGoal(goal.copyWith(monthlyContribution: null)), isNull);
  });

  test('a blank name is required', () {
    expect(messageFor(goal.copyWith(name: '   ')), errors.nameRequired);
  });

  test('the target must be above 0', () {
    expect(messageFor(goal.copyWith(targetAmount: 0)), errors.targetPositive);
    expect(messageFor(goal.copyWith(targetAmount: -5)), errors.targetPositive);
  });

  test('saved and monthly amounts cannot be negative', () {
    expect(messageFor(goal.copyWith(savedAmount: -1)), errors.amountPositive);
    expect(
      messageFor(goal.copyWith(monthlyContribution: -1)),
      errors.amountPositive,
    );
  });

  test('no amount may pass the maximum', () {
    const tooLarge = AppConstants.maxAmount + 1;
    for (final tooBig in [
      goal.copyWith(targetAmount: tooLarge),
      goal.copyWith(savedAmount: tooLarge),
      goal.copyWith(monthlyContribution: tooLarge),
    ]) {
      expect(messageFor(tooBig), errors.amountTooLarge);
    }
  });

  test('failures carry the user-message code', () {
    expect(goalInputFailure('x').errorCode, FailureCodes.userMessage);
  });
}
