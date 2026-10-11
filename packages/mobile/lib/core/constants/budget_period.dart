import 'package:expense_tracker/i18n/strings.g.dart';

enum BudgetPeriod {
  weekly,
  monthly,
  yearly;

  String get displayName {
    final period = t.enums.period;

    return switch (this) {
      BudgetPeriod.weekly => period.weekly,
      BudgetPeriod.monthly => period.monthly,
      BudgetPeriod.yearly => period.yearly,
    };
  }
}
