import 'package:expense_tracker/core/theme/currency_config.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Expenzo';

  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String dbDateFormat = 'yyyy-MM-dd';
  static const String dbDateTimeFormat = 'yyyy-MM-ddTHH:mm:ssZ';

  static const Duration undoSnackbarDuration = Duration(seconds: 10);
  static const Duration briefSnackbarDuration = Duration(seconds: 1);
  static const int? maxDescriptionLength = null;
  static const String defaultCurrencySymbol = CurrencyConfig.defaultSymbol;
  static const Duration animationDurationStandard = Duration(milliseconds: 300);
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  static const int defaultPaginationLimit = 20;
  static const int maxPaginationLimit = 100;

  static const String defaultEmoji = '📦';
  static const String defaultColor = '#2196F3';

  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const List<String> googleSignInScopes = ['email', 'profile'];
}
