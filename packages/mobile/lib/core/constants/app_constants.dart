class AppConstants {
  static const String appName = 'Expenzo';

  static const double maxAmount = 9999999999.99;

  static const double needsShare = 0.5;
  static const double wantsShare = 0.3;
  static const double savingsShare = 0.2;

  static const List<int> goalTimelineMonths = [1, 3, 6, 12];

  static final DateTime pickerFirstDate = DateTime(2000);
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String dbDateFormat = 'yyyy-MM-dd';
  static const String dbDateTimeFormat = 'yyyy-MM-ddTHH:mm:ssZ';
  static const Duration undoSnackbarDuration = Duration(seconds: 10);
  static const Duration briefSnackbarDuration = Duration(seconds: 1);
  static const int? maxDescriptionLength = null;
  static const Duration animationDurationStandard = Duration(milliseconds: 300);
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  static const double maxTextScale = 2.0;

  static const int minStoreStars = 4;
  static const int defaultPaginationLimit = 20;
  static const int maxPaginationLimit = 100;
  static const String defaultEmoji = '📦';
  static const String defaultColor = '#2196F3';
  static const String defaultCategoryName = 'General';

  static const String defaultBudgetName = 'Unnamed budget';

  static const int budgetNameMaxLength = 100;

  static const int groupNameMaxLength = 60;

  static const int fillBudgetNamesBatchSize = 200;

  static const int fillRecordBudgetLinksBatchSize = 200;

  static const int weeklySummaryHour = 20;

  static const int recurringReminderHour = 9;

  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const List<String> googleSignInScopes = ['email', 'profile'];

  AppConstants._();
}
