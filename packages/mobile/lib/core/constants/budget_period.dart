import 'package:expense_tracker/i18n/strings.g.dart';

enum BudgetPeriod {
  weekly,
  monthly,
  yearly;

  String get displayName {
    return switch (this) {
      BudgetPeriod.weekly => t.enums.period.weekly,
      BudgetPeriod.monthly => t.enums.period.monthly,
      BudgetPeriod.yearly => t.enums.period.yearly,
    };
  }
}
