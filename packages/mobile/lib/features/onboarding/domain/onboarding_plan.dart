import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/next_occurrence.dart';

import 'entities/onboarding_draft.dart';

double recurringMonthlyTotal(List<RecurringDraft> items) =>
    items.fold(0, (sum, item) => sum + item.monthlyAmount);

/// Income left after recurring payments, the amount the plan splits.
double planBaseFor(OnboardingDraft draft) {
  final income = draft.monthlyIncome;

  return income == null ? 0 : income - recurringMonthlyTotal(draft.recurring);
}

class TimelineOption extends Equatable {
  final int months;
  final double monthlyAmount;

  @override
  List<Object?> get props => [months, monthlyAmount];

  const TimelineOption({required this.months, required this.monthlyAmount});
}

/// What reaching [target] in each preset number of months costs per month.
List<TimelineOption> timelineOptions({required double target}) => [
  for (final months in AppConstants.goalTimelineMonths)
    _option(target: target, months: months),
];

TimelineOption customTimeline({
  required double target,
  required DateTime from,
  required DateTime date,
}) {
  var months = (date.year - from.year) * 12 + date.month - from.month;
  if (date.day < from.day) months--;

  return _option(target: target, months: months < 1 ? 1 : months);
}

DateTime targetDateFor(DateTime from, int months) => addMonths(from, months);

TimelineOption _option({required double target, required int months}) =>
    TimelineOption(months: months, monthlyAmount: roundMoney(target / months));
