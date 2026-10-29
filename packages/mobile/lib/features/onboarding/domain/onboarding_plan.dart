import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budgets/domain/budget_plan.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/next_occurrence.dart';

import 'entities/onboarding_draft.dart';

double recurringMonthlyTotal(List<RecurringDraft> items) =>
    items.fold(0, (sum, item) => sum + item.monthlyAmount);

/// Income left after recurring payments, the amount the plan splits.
double planBaseFor(OnboardingDraft draft) {
  final income = draft.monthlyIncome;

  return income == null ? 0 : income - recurringMonthlyTotal(draft.recurring);
}

/// The rows the user submitted, or the suggestion before they have.
List<PlanRow> planRowsFor(OnboardingDraft draft) =>
    draft.budgetRows ?? suggestedPlanRows(planBaseFor(draft));

enum TimelineFit { affordable, tooExpensive, slow }

class TimelineOption extends Equatable {
  final int months;
  final double monthlyAmount;
  final TimelineFit fit;

  @override
  List<Object?> get props => [months, monthlyAmount, fit];

  const TimelineOption({
    required this.months,
    required this.monthlyAmount,
    required this.fit,
  });
}

List<TimelineOption> timelineOptions({
  required double target,
  required double savingsPerMonth,
}) => [
  for (final months in AppConstants.goalTimelineMonths)
    _option(target: target, months: months, savingsPerMonth: savingsPerMonth),
];

int? fastestAffordableMonths(List<TimelineOption> options) {
  for (final option in options) {
    if (option.fit != TimelineFit.tooExpensive) return option.months;
  }

  return null;
}

TimelineOption customTimeline({
  required double target,
  required DateTime from,
  required DateTime date,
  required double savingsPerMonth,
}) {
  var months = (date.year - from.year) * 12 + date.month - from.month;
  if (date.day < from.day) months--;

  return _option(
    target: target,
    months: months < 1 ? 1 : months,
    savingsPerMonth: savingsPerMonth,
  );
}

DateTime targetDateFor(DateTime from, int months) => addMonths(from, months);

TimelineOption _option({
  required double target,
  required int months,
  required double savingsPerMonth,
}) {
  final monthly = roundMoney(target / months);
  final last = AppConstants.goalTimelineMonths.last;
  final TimelineFit fit;
  if (savingsPerMonth <= 0) {
    fit = TimelineFit.affordable;
  } else if (monthly > savingsPerMonth) {
    fit = TimelineFit.tooExpensive;
  } else {
    fit = months >= last ? TimelineFit.slow : TimelineFit.affordable;
  }

  return TimelineOption(months: months, monthlyAmount: monthly, fit: fit);
}
