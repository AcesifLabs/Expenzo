/// How often the income typed on the first onboarding page arrives.
enum IncomeFrequency {
  monthly,
  biWeekly,
  weekly;

  /// [amount] per this period, as a monthly amount.
  double toMonthly(double amount) => switch (this) {
    IncomeFrequency.monthly => amount,
    IncomeFrequency.biWeekly => amount * 26 / 12,
    IncomeFrequency.weekly => amount * 52 / 12,
  };
}
