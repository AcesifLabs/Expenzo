enum IncomeFrequency {
  monthly,
  biWeekly,
  weekly;

  double toMonthly(double amount) => switch (this) {
    IncomeFrequency.monthly => amount,
    IncomeFrequency.biWeekly => amount * 26 / 12,
    IncomeFrequency.weekly => amount * 52 / 12,
  };
}
