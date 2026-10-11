import 'package:expense_tracker/i18n/strings.g.dart';

enum TransactionFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  yearly;

  String get displayName {
    final labels = t.enums.frequency;

    return switch (this) {
      TransactionFrequency.daily => labels.daily,
      TransactionFrequency.weekly => labels.weekly,
      TransactionFrequency.biweekly => labels.biweekly,
      TransactionFrequency.monthly => labels.monthly,
      TransactionFrequency.yearly => labels.yearly,
    };
  }
}
