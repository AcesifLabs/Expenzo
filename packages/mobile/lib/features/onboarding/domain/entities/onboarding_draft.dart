import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/monthly_equivalent.dart';

class RecurringDraft extends Equatable {
  final String description;
  final double amount;
  final RecurringFrequency frequency;

  double get monthlyAmount => monthlyEquivalent(amount, frequency);

  @override
  List<Object?> get props => [description, amount, frequency];

  const RecurringDraft({
    required this.description,
    required this.amount,
    required this.frequency,
  });
}

class GoalDraft extends Equatable {
  final String name;
  final double targetAmount;
  final int? months;
  final DateTime? customDate;

  @override
  List<Object?> get props => [name, targetAmount, months, customDate];

  const GoalDraft({
    required this.name,
    required this.targetAmount,
    this.months,
    this.customDate,
  });

  GoalDraft withTimeline({int? months, DateTime? customDate}) => GoalDraft(
    name: name,
    targetAmount: targetAmount,
    months: months,
    customDate: customDate,
  );
}

class OnboardingDraft extends Equatable {
  final double? monthlyIncome;
  final List<RecurringDraft> recurring;

  /// The plan step's rows. Null until that step is submitted; empty when
  /// the user skipped budgets.
  final List<PlanRow>? budgetRows;
  final GoalDraft? goal;

  @override
  List<Object?> get props => [monthlyIncome, recurring, budgetRows, goal];

  const OnboardingDraft({
    this.monthlyIncome,
    this.recurring = const [],
    this.budgetRows,
    this.goal,
  });

  OnboardingDraft copyWith({
    double? monthlyIncome,
    List<RecurringDraft>? recurring,
    List<PlanRow>? budgetRows,
    GoalDraft? goal,
    bool clearGoal = false,
  }) {
    return OnboardingDraft(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      recurring: recurring ?? this.recurring,
      budgetRows: budgetRows ?? this.budgetRows,
      goal: clearGoal ? null : goal ?? this.goal,
    );
  }
}
