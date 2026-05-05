import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../../shared/services/notification_service.dart';

class CheckBudgetAlerts {
  final BudgetRepository budgetRepository;
  final NotificationService notificationService;

  CheckBudgetAlerts({
    required this.budgetRepository,
    required this.notificationService,
  });

  Future<Either<Failure, void>> call({
    required String budgetId,
    required double spentAmount,
  }) async {
    try {
      final result = await budgetRepository.getBudgetById(budgetId);

      return result.fold((failure) => Left(failure), (budget) async {
        // Calculate effective budget with rollover
        final effectiveBudget =
            budget.amount +
            (budget.rolloverEnabled ? budget.rolloverAmount : 0);

        // Calculate percentage
        final percentage = effectiveBudget > 0
            ? (spentAmount / effectiveBudget) * 100
            : 0.0;

        // Check thresholds and show notification
        if (percentage >= 100) {
          await notificationService.showBudgetAlert(
            budgetId: budgetId,
            budgetName: budget.categoryId ?? 'Overall Budget',
            percentage: percentage,
          );
        } else if (percentage >= 80) {
          await notificationService.showBudgetAlert(
            budgetId: budgetId,
            budgetName: budget.categoryId ?? 'Overall Budget',
            percentage: percentage,
          );
        }

        return const Right(null);
      });
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
