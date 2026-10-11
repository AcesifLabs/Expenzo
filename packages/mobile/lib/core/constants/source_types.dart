import 'package:expense_tracker/i18n/strings.g.dart';

enum ExpenseSource {
  manual,
  sms,
  email,
  recurring;

  String get displayName {
    final strings = t.enums.source;

    return switch (this) {
      ExpenseSource.manual => strings.manual,
      ExpenseSource.sms => strings.sms,
      ExpenseSource.email => strings.email,
      ExpenseSource.recurring => strings.recurring,
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
