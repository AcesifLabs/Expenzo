import 'package:expense_tracker/i18n/strings.g.dart';

enum TransactionFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  yearly;

  String get displayName {
    return switch (this) {
      TransactionFrequency.daily => t.enums.frequency.daily,
      TransactionFrequency.weekly => t.enums.frequency.weekly,
      TransactionFrequency.biweekly => t.enums.frequency.biweekly,
      TransactionFrequency.monthly => t.enums.frequency.monthly,
      TransactionFrequency.yearly => t.enums.frequency.yearly,
    };
  }
}
