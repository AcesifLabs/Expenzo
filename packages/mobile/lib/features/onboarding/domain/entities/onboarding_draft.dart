import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';

/// A fixed expense typed on the recurring onboarding page.
class RecurringDraft extends Equatable {
  final String description;
  final double amount;
  final RecurringFrequency frequency;

  /// [amount] as a monthly amount.
  double get monthlyAmount => switch (frequency) {
    RecurringFrequency.daily => amount * 365 / 12,
    RecurringFrequency.weekly => amount * 52 / 12,
    RecurringFrequency.monthly => amount,
    RecurringFrequency.yearly => amount / 12,
  };

  @override
  List<Object?> get props => [description, amount, frequency];

  const RecurringDraft({
    required this.description,
    required this.amount,
    required this.frequency,
  });
}

/// The savings goal typed during onboarding. [months] or [customDate] is the
/// chosen timeline (null until the user picks one).
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

  /// A timeline choice replaces the other kind: months clear the custom date
  /// and the other way round.
  GoalDraft withTimeline({int? months, DateTime? customDate}) => GoalDraft(
    name: name,
    targetAmount: targetAmount,
    months: months,
    customDate: customDate,
  );
}

/// What onboarding has collected. Each field is set only when the user taps
/// Continue on its page.
class OnboardingDraft extends Equatable {
  final double? monthlyIncome;
  final List<RecurringDraft> recurring;
  final bool createBudgets;
  final GoalDraft? goal;

  @override
  List<Object?> get props => [monthlyIncome, recurring, createBudgets, goal];

  const OnboardingDraft({
    this.monthlyIncome,
    this.recurring = const [],
    this.createBudgets = false,
    this.goal,
  });

  /// [goal] can be cleared by passing [clearGoal].
  OnboardingDraft copyWith({
    double? monthlyIncome,
    List<RecurringDraft>? recurring,
    bool? createBudgets,
    GoalDraft? goal,
    bool clearGoal = false,
  }) {
    return OnboardingDraft(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      recurring: recurring ?? this.recurring,
      createBudgets: createBudgets ?? this.createBudgets,
      goal: clearGoal ? null : goal ?? this.goal,
    );
  }
}
