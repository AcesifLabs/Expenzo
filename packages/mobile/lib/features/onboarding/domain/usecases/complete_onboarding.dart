import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/repositories/goal_repository.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/next_occurrence.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../entities/onboarding_draft.dart';
import '../entities/onboarding_result.dart';
import '../onboarding_plan.dart';

class CompleteOnboarding {
  final RecurringRepository recurringRepository;
  final BudgetRepository budgetRepository;
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;

  CompleteOnboarding({
    required this.recurringRepository,
    required this.budgetRepository,
    required this.goalRepository,
    required this.settingsRepository,
  });

  Future<Either<Failure, OnboardingResult>> call(
    OnboardingDraft draft, {
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    var hadErrors = false;

    final recurringCount = await _saveRecurring(draft.recurring, at);
    hadErrors = recurringCount < draft.recurring.length;
    var budgetsCreated = false;
    if (!hadErrors) {
      budgetsCreated = await _saveBudgets(draft, at);
      hadErrors =
          draft.createBudgets && !budgetsCreated && !_split(draft).isEmpty;
    }
    String? goalName;
    final goal = draft.goal;
    if (!hadErrors && goal != null) {
      goalName = await _saveGoal(goal, at);
      hadErrors = goalName == null;
    }

    final saved = await _markDone(draft, at);

    return saved.map(
      (_) => OnboardingResult(
        recurringCount: recurringCount,
        budgetsCreated: budgetsCreated,
        goalName: goalName,
        hadErrors: hadErrors,
      ),
    );
  }

  Future<int> _saveRecurring(List<RecurringDraft> items, DateTime at) async {
    var saved = 0;
    for (final item in items) {
      final result = await recurringRepository.createRecurring(
        RecurringTransaction(
          description: item.description,
          amount: item.amount,
          frequency: item.frequency,
          startDate: at,
          nextOccurrence: calculateNextOccurrence(at, item.frequency),
        ),
      );
      if (_failed(result, 'recurring item')) return saved;
      saved++;
    }

    return saved;
  }

  Future<bool> _saveBudgets(OnboardingDraft draft, DateTime at) async {
    final split = _split(draft);
    if (!draft.createBudgets || split.isEmpty) return false;
    final names = t.onboarding.budgetNames;
    final shares = {
      names.needs: split.needs,
      names.wants: split.wants,
      names.savings: split.savings,
    };
    for (final MapEntry(key: name, value: amount) in shares.entries) {
      if (amount <= 0) continue;
      final result = await budgetRepository.createBudget(
        Budget(
          name: name,
          amount: amount,
          period: BudgetPeriod.monthly,
          startDate: DateTime(at.year, at.month, 1),
        ),
      );
      if (_failed(result, 'budget')) return false;
    }

    return true;
  }

  Future<String?> _saveGoal(GoalDraft draft, DateTime at) async {
    final custom = draft.customDate;
    final months = custom != null
        ? customTimeline(
            target: draft.targetAmount,
            from: at,
            date: custom,
            savingsPerMonth: 0,
          ).months
        : draft.months;
    final result = await goalRepository.createGoal(
      Goal(
        name: draft.name,
        targetAmount: draft.targetAmount,
        targetDate:
            custom ?? (months == null ? null : targetDateFor(at, months)),
        monthlyContribution: months == null
            ? null
            : draft.targetAmount / months,
      ),
    );

    return _failed(result, 'goal') ? null : draft.name;
  }

  Future<Either<Failure, Unit>> _markDone(
    OnboardingDraft draft,
    DateTime at,
  ) async {
    final loaded = await settingsRepository.getSettings();

    return loaded.fold(Left.new, (settings) async {
      final saved = await settingsRepository.updateSettings(
        settings.copyWith(
          onboardingCompleted: true,
          monthlyIncome: draft.monthlyIncome ?? settings.monthlyIncome,
          updatedAt: at.toUtc(),
        ),
      );

      return saved.map((_) => unit);
    });
  }

  BudgetSplit _split(OnboardingDraft draft) => budgetSplitFor(
    monthlyIncome: draft.monthlyIncome,
    recurringTotal: recurringMonthlyTotal(draft.recurring),
  );

  bool _failed(Either<Failure, Object?> result, String what) =>
      result.fold((f) {
        appLogger.error('Onboarding could not save a $what', f);

        return true;
      }, (_) => false);
}
