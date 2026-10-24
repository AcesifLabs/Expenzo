import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/next_occurrence.dart';

import 'entities/onboarding_draft.dart';

/// The recurring items' total per month.
double recurringMonthlyTotal(List<RecurringDraft> items) =>
    items.fold(0, (sum, item) => sum + item.monthlyAmount);

/// Income left after recurring payments, split 50/30/20.
class BudgetSplit extends Equatable {
  static const empty = BudgetSplit(base: 0, needs: 0, wants: 0, savings: 0);

  final double base;
  final double needs;
  final double wants;
  final double savings;

  bool get isEmpty => base <= 0;

  @override
  List<Object?> get props => [base, needs, wants, savings];

  const BudgetSplit({
    required this.base,
    required this.needs,
    required this.wants,
    required this.savings,
  });
}

/// The empty split when income was skipped or recurring payments use all of
/// it; never negative. Shares are rounded to cents, with any remainder given
/// to Needs so the three add up to [BudgetSplit.base].
BudgetSplit budgetSplitFor({
  required double? monthlyIncome,
  required double recurringTotal,
}) {
  if (monthlyIncome == null || recurringTotal >= monthlyIncome) {
    return BudgetSplit.empty;
  }
  final base = _cents(monthlyIncome - recurringTotal);
  final wants = _cents(base * AppConstants.wantsShare);
  final savings = _cents(base * AppConstants.savingsShare);

  return BudgetSplit(
    base: base,
    needs: _cents(base - wants - savings),
    wants: wants,
    savings: savings,
  );
}

double _cents(double amount) => (amount * 100).roundToDouble() / 100;

/// ✓ affordable, ✗ more than the monthly savings, ⚠ affordable but slow.
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

/// One option per [AppConstants.goalTimelineMonths]. With no savings (an
/// empty split) every option counts as affordable and no marks are shown.
List<TimelineOption> timelineOptions({
  required double target,
  required double savingsPerMonth,
}) => [
  for (final months in AppConstants.goalTimelineMonths)
    _option(target: target, months: months, savingsPerMonth: savingsPerMonth),
];

/// The shortest affordable option, for "You can afford it in N months".
int? fastestAffordableMonths(List<TimelineOption> options) {
  for (final option in options) {
    if (option.fit != TimelineFit.tooExpensive) return option.months;
  }

  return null;
}

/// The option for a picked [date]: whole calendar months from [from], at
/// least 1.
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

/// The same day [months] later, clamped to the end of that month.
DateTime targetDateFor(DateTime from, int months) => addMonths(from, months);

TimelineOption _option({
  required double target,
  required int months,
  required double savingsPerMonth,
}) {
  final monthly = _cents(target / months);
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
