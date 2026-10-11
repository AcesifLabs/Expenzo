import 'package:expense_tracker/i18n/strings.g.dart';

enum ExpenseSource {
  manual,
  sms,
  email,
  recurring;

  String get displayName {
    return switch (this) {
      ExpenseSource.manual => t.enums.source.manual,
      ExpenseSource.sms => t.enums.source.sms,
      ExpenseSource.email => t.enums.source.email,
      ExpenseSource.recurring => t.enums.source.recurring,
    };
  }

  String get icon {
    switch (this) {
      case ExpenseSource.manual:
        return '✏️';
      case ExpenseSource.sms:
        return '💬';
      case ExpenseSource.email:
        return '📧';
      case ExpenseSource.recurring:
        return '🔄';
    }
  }
}

class AppSourceType {
  static const String sms = 'sms';
  static const String email = 'email';
  static const String manual = 'manual';
  static const String recurring = 'recurring';
}
