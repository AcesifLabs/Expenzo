import 'package:equatable/equatable.dart';

import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';

import '../../domain/entities/income_frequency.dart';
import '../../domain/entities/onboarding_draft.dart';

sealed class OnboardingEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const OnboardingEvent();
}

class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

class IncomeSubmitted extends OnboardingEvent {
  final double amount;
  final IncomeFrequency frequency;

  @override
  List<Object?> get props => [amount, frequency];

  const IncomeSubmitted(this.amount, this.frequency);
}

class RecurringItemAdded extends OnboardingEvent {
  final RecurringDraft item;

  @override
  List<Object?> get props => [item];

  const RecurringItemAdded(this.item);
}

class RecurringItemRemoved extends OnboardingEvent {
  final int index;

  @override
  List<Object?> get props => [index];

  const RecurringItemRemoved(this.index);
}

class RecurringSubmitted extends OnboardingEvent {
  const RecurringSubmitted();
}

class BudgetPlanSubmitted extends OnboardingEvent {
  final List<PlanRow> rows;

  @override
  List<Object?> get props => [rows];

  const BudgetPlanSubmitted(this.rows);
}

class GoalSubmitted extends OnboardingEvent {
  final String name;
  final double target;

  @override
  List<Object?> get props => [name, target];

  const GoalSubmitted(this.name, this.target);
}

class GoalDeclined extends OnboardingEvent {
  const GoalDeclined();
}

class TimelineChosen extends OnboardingEvent {
  final int? months;
  final DateTime? customDate;

  @override
  List<Object?> get props => [months, customDate];

  const TimelineChosen({this.months, this.customDate});
}

class OnboardingStepBack extends OnboardingEvent {
  const OnboardingStepBack();
}

class OnboardingFinished extends OnboardingEvent {
  const OnboardingFinished();
}

class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}
