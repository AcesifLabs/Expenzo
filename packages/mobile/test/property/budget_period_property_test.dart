import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/utils/budget_period_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

void main() {
  property('the period holds the day and touches its neighbours', () {
    forAll(
      combine3(anyDateTime(), anyDateTime(), constantFrom(BudgetPeriod.values)),
      maxExamples: propertyTrials,
      (v) {
        final (budgetStart, now, period) = v;
        final current = BudgetPeriodUtils.calculatePeriodAt(
          budgetStart,
          period,
          now,
        );
        expect(current.start.isAfter(now), isFalse);
        expect(now.isBefore(current.end), isTrue);

        final next = BudgetPeriodUtils.calculatePeriodAt(
          budgetStart,
          period,
          current.end,
        );
        expect(next.start, current.end, reason: 'no gap or overlap after');
        final previous = BudgetPeriodUtils.previousPeriod(
          budgetStart,
          period,
          current,
        );
        expect(previous.end, current.start, reason: 'no gap or overlap before');
      },
    );
  });
}
