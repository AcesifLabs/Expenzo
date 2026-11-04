abstract final class BackgroundTaskNames {
  static const weeklySummary = 'expenzo.weeklySummary';
  static const recurringReminders = 'expenzo.recurringReminders';

  /// Queued by the Android SMS receiver when the app is not running. Must
  /// match `SmsImportScheduler.TASK_NAME` in Kotlin.
  static const smsImport = 'expenzo.smsImport';
}
