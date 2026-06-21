enum TransactionFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case TransactionFrequency.daily:
        return 'Daily';
      case TransactionFrequency.weekly:
        return 'Weekly';
      case TransactionFrequency.biweekly:
        return 'Biweekly';
      case TransactionFrequency.monthly:
        return 'Monthly';
      case TransactionFrequency.yearly:
        return 'Yearly';
    }
  }
}
