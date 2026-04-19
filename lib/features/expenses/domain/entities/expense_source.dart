enum ExpenseSource {
  manual,
  sms,
  email,
  recurring;

  String get displayName {
    switch (this) {
      case ExpenseSource.manual:
        return 'Manual';
      case ExpenseSource.sms:
        return 'SMS';
      case ExpenseSource.email:
        return 'Email';
      case ExpenseSource.recurring:
        return 'Recurring';
    }
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
