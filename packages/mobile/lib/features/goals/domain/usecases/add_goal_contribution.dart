import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../entities/goal.dart';
import '../repositories/goal_repository.dart';
import 'validate_goal.dart';

class AddGoalContributionParams extends Equatable {
  final String goalId;
  final double amount;

  @override
  List<Object?> get props => [goalId, amount];

  const AddGoalContributionParams({required this.goalId, required this.amount});
}

class AddGoalContribution {
  final GoalRepository repository;

  AddGoalContribution({required this.repository});

  Future<Either<Failure, Goal>> call(AddGoalContributionParams params) async {
    final errors = t.goals.errors;
    if (params.amount <= 0) {
      return Left(goalInputFailure(errors.amountPositive));
    }
    final loaded = await repository.getGoalById(params.goalId);

    return loaded.fold(Left.new, (goal) {
      final saved = goal.savedAmount + params.amount;
      if (saved > AppConstants.maxAmount) {
        return Left(goalInputFailure(errors.amountTooLarge));
      }

      return repository.updateGoal(goal.copyWith(savedAmount: saved));
    });
  }
}
