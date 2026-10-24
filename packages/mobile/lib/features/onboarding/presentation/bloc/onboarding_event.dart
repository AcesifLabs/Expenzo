import 'package:equatable/equatable.dart';

import '../../domain/entities/income_frequency.dart';
import '../../domain/entities/onboarding_draft.dart';

sealed class OnboardingEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const OnboardingEvent();
}

/// Prefills the saved income (Replay setup).
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
  final bool createBudgets;

  @override
  List<Object?> get props => [createBudgets];

  const BudgetPlanSubmitted(this.createBudgets);
}

class GoalSubmitted extends OnboardingEvent {
  final String name;
  final double target;

  @override
  List<Object?> get props => [name, target];

  const GoalSubmitted(this.name, this.target);
}

/// "No goal for now".
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

/// Back to the previous setup page (Q24).
class OnboardingStepBack extends OnboardingEvent {
  const OnboardingStepBack();
}

class OnboardingFinished extends OnboardingEvent {
  const OnboardingFinished();
}

/// Ends setup, keeping what was confirmed with Continue (Q24).
class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}
