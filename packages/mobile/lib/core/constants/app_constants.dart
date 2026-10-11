class AppConstants {
  static const String appName = 'Expenzo';
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

  /// Most names one `POST /budgets/names` request may carry
  /// (`FILL_BUDGET_NAMES_MAX_ITEMS`).
  static const int fillBudgetNamesBatchSize = 200;

  /// Most links one `POST /records/budget-links` request may carry
  /// (`FILL_RECORD_BUDGET_LINKS_MAX_ITEMS`).
  static const int fillRecordBudgetLinksBatchSize = 200;

  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const List<String> googleSignInScopes = ['email', 'profile'];

  AppConstants._();
}
