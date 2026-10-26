import 'package:expense_tracker/i18n/strings.g.dart';

enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get displayName => switch (this) {
    RecurringFrequency.daily => t.enums.frequency.daily,
    RecurringFrequency.weekly => t.enums.frequency.weekly,
    RecurringFrequency.monthly => t.enums.frequency.monthly,
    RecurringFrequency.yearly => t.enums.frequency.yearly,
  };
}
