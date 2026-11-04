import 'package:flutter_test/flutter_test.dart';
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
  });

  test('no income gives a base of 0', () {
    expect(planBaseFor(const OnboardingDraft(recurring: [rent])), 0);
  });

  test('timeline options run 3 to 15 months at target / months', () {
    final options = timelineOptions(target: 1999);

    expect(options.map((o) => o.months), [3, 6, 9, 12, 15]);
    expect(options.map((o) => o.monthlyAmount), [
      666.33,
      333.17,
      222.11,
      166.58,
      133.27,
    ]);
  });

  test('a custom date counts calendar months, at least 1', () {
    final from = DateTime(2026, 10, 24);

    TimelineOption custom(DateTime date) =>
        customTimeline(target: 1000, from: from, date: date);

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
