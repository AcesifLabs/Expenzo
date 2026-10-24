class AppConstants {
  static const String appName = 'Expenzo';

  /// Largest amount the backend stores (`decimal(12,2)`).
  static const double maxAmount = 9999999999.99;

  /// Onboarding budget plan: a fixed 50/30/20 split (ADR 0011 cuts the
  /// design's "Drag to adjust").
  static const double needsShare = 0.5;
  static const double wantsShare = 0.3;
  static const double savingsShare = 0.2;

  /// Months offered on the onboarding goal timeline.
  static const List<int> goalTimelineMonths = [1, 3, 6, 12];

  /// The earliest day a date picker offers.
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

  /// Device large text × Extra large can exceed what layouts survive; cap the
  /// product. Overflow tests run at this value.
  static const double maxTextScale = 2.0;

  /// Rate the app: this many stars or more go to the store review; fewer
  /// open the feedback email instead.
  static const int minStoreStars = 4;
  static const int defaultPaginationLimit = 20;
  static const int maxPaginationLimit = 100;
  static const String defaultEmoji = '📦';
  static const String defaultColor = '#2196F3';
  static const String defaultCategoryName = 'General';

  /// Name for a budget that has none; the backend uses the same text
  /// (`DEFAULT_BUDGET_NAME` in packages/backend/src/budgets/budgets.constants.ts).
  static const String defaultBudgetName = 'Unnamed budget';

  /// Longest budget name the backend accepts (`BUDGET_NAME_MAX_LENGTH`).
  static const int budgetNameMaxLength = 100;

  /// Longest Family Group name (backend GROUP_NAME_MAX_LENGTH).
  static const int groupNameMaxLength = 60;

  /// Most names one `POST /budgets/names` request may carry
  /// (`FILL_BUDGET_NAMES_MAX_ITEMS`).
  static const int fillBudgetNamesBatchSize = 200;

  /// Most links one `POST /records/budget-links` request may carry
  /// (`FILL_RECORD_BUDGET_LINKS_MAX_ITEMS`).
  static const int fillRecordBudgetLinksBatchSize = 200;

  /// Local hour the weekly summary goes out, on the day before the week starts.
  static const int weeklySummaryHour = 20;

  /// Local hour recurring reminders go out, on the day before the due date.
  static const int recurringReminderHour = 9;

  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const List<String> googleSignInScopes = ['email', 'profile'];

  AppConstants._();
}
