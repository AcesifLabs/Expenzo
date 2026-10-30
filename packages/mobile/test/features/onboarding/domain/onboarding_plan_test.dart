import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/income_frequency.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/domain/onboarding_plan.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';

void main() {
  double cents(double v) => (v * 100).roundToDouble() / 100;

  test('income frequencies convert to a month', () {
    expect(cents(IncomeFrequency.weekly.toMonthly(1000)), 4333.33);
    expect(cents(IncomeFrequency.biWeekly.toMonthly(1000)), 2166.67);
    expect(IncomeFrequency.monthly.toMonthly(1000), 1000);
  });

  test('recurring items convert to a month', () {
    RecurringDraft draft(RecurringFrequency f) =>
        RecurringDraft(description: 'x', amount: 120, frequency: f);

    expect(cents(draft(RecurringFrequency.daily).monthlyAmount), 3650);
    expect(cents(draft(RecurringFrequency.weekly).monthlyAmount), 520);
    expect(draft(RecurringFrequency.monthly).monthlyAmount, 120);
    expect(draft(RecurringFrequency.yearly).monthlyAmount, 10);
  });

  const rent = RecurringDraft(
    description: 'Rent',
    amount: 1225,
    frequency: RecurringFrequency.monthly,
  );

  test('the design numbers: 5,000 income, 1,225 recurring', () {
    const draft = OnboardingDraft(monthlyIncome: 5000, recurring: [rent]);

    expect(planBaseFor(draft), 3775);
    expect(planRowsFor(draft).map((r) => r.amount), [1887.5, 1132.5, 755]);
  });

  test('no income gives a base of 0', () {
    expect(planBaseFor(const OnboardingDraft(recurring: [rent])), 0);
  });

  test('submitted rows win over the suggestion', () {
    const rows = [PlanRow(key: 'k', name: 'Food', amount: 10)];
    const draft = OnboardingDraft(monthlyIncome: 5000, budgetRows: rows);

    expect(planRowsFor(draft), rows);
    expect(planRowsFor(draft.copyWith(budgetRows: const [])), isEmpty);
  });

  test('the design timeline: 1,999 with 755 savings', () {
    final options = timelineOptions(target: 1999, savingsPerMonth: 755);

    expect(options.map((o) => o.fit), [
      TimelineFit.tooExpensive,
      TimelineFit.affordable,
      TimelineFit.affordable,
      TimelineFit.slow,
    ]);
    expect(fastestAffordableMonths(options), 3);
  });

  test('with no savings every option is affordable', () {
    final options = timelineOptions(target: 1999, savingsPerMonth: 0);

    expect(options.every((o) => o.fit == TimelineFit.affordable), isTrue);
  });

  test('a custom date counts calendar months, at least 1', () {
    final from = DateTime(2026, 10, 24);

    TimelineOption custom(DateTime date) => customTimeline(
      target: 1000,
      from: from,
      date: date,
      savingsPerMonth: 500,
    );

    expect(custom(DateTime(2026, 12, 24)).months, 2);
    expect(custom(DateTime(2026, 10, 25)).months, 1);
  });

  test('targetDateFor clamps to the end of the month', () {
    expect(targetDateFor(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(targetDateFor(DateTime(2026, 10, 24), 3), DateTime(2027, 1, 24));
  });

  test('recurringMonthlyTotal adds the monthly amounts', () {
    expect(
      recurringMonthlyTotal(const [
        RecurringDraft(
          description: 'Rent',
          amount: 1200,
          frequency: RecurringFrequency.monthly,
        ),
        RecurringDraft(
          description: 'Netflix',
          amount: 15.49,
          frequency: RecurringFrequency.monthly,
        ),
      ]),
      1215.49,
    );
  });
}
