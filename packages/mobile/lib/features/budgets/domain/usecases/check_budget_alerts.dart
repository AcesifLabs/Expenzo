import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../../shared/services/notification_service.dart';

class CheckBudgetAlerts {
  final BudgetRepository budgetRepository;
  final NotificationService notificationService;

  CheckBudgetAlerts({
    required this.budgetRepository,
    required this.notificationService,
  });

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.

  Future<Either<Failure, Unit>> call({
    required String budgetId,
    required double spentAmount,
  }) async {
    try {
      final result = await budgetRepository.getBudgetById(budgetId);

      return result.fold((failure) => Left(failure), (budget) async {
        final effectiveBudget =
            budget.amount +
            (budget.rolloverEnabled ? budget.rolloverAmount : 0);

        final percentage = effectiveBudget > 0
            ? (spentAmount / effectiveBudget) * 100
            : 0.0;

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

        return const Right(unit);
      });
    } catch (e, s) {
      appLogger.error('Error checking budget alerts', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }
}
