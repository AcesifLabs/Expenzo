import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

import '../../support/factories/budget_factory.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockBudgetRepository repository;
  late MockNotificationService notificationService;
  late CheckBudgetAlerts useCase;

  setUpAll(() {
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  });

  setUp(() {
    repository = MockBudgetRepository();
    notificationService = MockNotificationService();
    useCase = CheckBudgetAlerts(
      budgetRepository: repository,
      notificationService: notificationService,
    );
    when(
      () => notificationService.showBudgetAlert(
        budgetId: any(named: 'budgetId'),
        budgetName: any(named: 'budgetName'),
        percentage: any(named: 'percentage'),
      ),
    ).thenAnswer((_) async {});
  });

  test('fires an alert at exactly 80% (inclusive threshold)', () async {
    when(() => repository.getBudgetById('b1')).thenAnswer(
      (_) async => Right(makeBudget(id: 'b1', name: 'Food', amount: 100)),
    );

    await useCase(budgetId: 'b1', spentAmount: 80);

    verify(
      () => notificationService.showBudgetAlert(
        budgetId: 'b1',
        budgetName: 'Food',
        percentage: 80.0,
      ),
    ).called(1);
  });

  test('fires an alert when over budget', () async {
    when(
      () => repository.getBudgetById('b1'),
    ).thenAnswer((_) async => Right(makeBudget(id: 'b1', amount: 100)));

    await useCase(budgetId: 'b1', spentAmount: 120);

    verify(
      () => notificationService.showBudgetAlert(
        budgetId: any(named: 'budgetId'),
        budgetName: any(named: 'budgetName'),
        percentage: 120.0,
      ),
    ).called(1);
  });

  test('does not fire below 80%', () async {
    when(
      () => repository.getBudgetById('b1'),
    ).thenAnswer((_) async => Right(makeBudget(id: 'b1', amount: 100)));

    await useCase(budgetId: 'b1', spentAmount: 79);

    verifyNever(
      () => notificationService.showBudgetAlert(
        budgetId: any(named: 'budgetId'),
        budgetName: any(named: 'budgetName'),
        percentage: any(named: 'percentage'),
      ),
    );
  });

  test('rollover raises the denominator, suppressing an alert', () async {
    // Without rollover, 80/100 = 80% would alert. With +100 rollover,
    // 80/200 = 40% must not alert.
    when(() => repository.getBudgetById('b1')).thenAnswer(
      (_) async => Right(
        makeBudget(
          id: 'b1',
          amount: 100,
          rolloverEnabled: true,
          rolloverAmount: 100,
        ),
      ),
    );

    await useCase(budgetId: 'b1', spentAmount: 80);

    verifyNever(
      () => notificationService.showBudgetAlert(
        budgetId: any(named: 'budgetId'),
        budgetName: any(named: 'budgetName'),
        percentage: any(named: 'percentage'),
      ),
    );
  });

  test(
    'returns Left and does not alert when the budget lookup fails',
    () async {
      when(
        () => repository.getBudgetById('b1'),
      ).thenAnswer((_) async => const Left(CacheFailure(message: 'boom')));

      final result = await useCase(budgetId: 'b1', spentAmount: 90);

      expect(result.isLeft(), true);
      verifyNever(
        () => notificationService.showBudgetAlert(
          budgetId: any(named: 'budgetId'),
          budgetName: any(named: 'budgetName'),
          percentage: any(named: 'percentage'),
        ),
      );
    },
  );
}
