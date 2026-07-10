import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String login = '/auth/login';
  static const String records = '/records';
  static const String recordsBulk = '/records/bulk';
  static const String categories = '/categories';
  static const String budgets = '/budgets';
  static const String messageSources = '/message-sources';
  static const String expenseTemplates = '/expense-templates';
  static const String parsingRules = '/parsing-rules';
  static const String recurringTransactions = '/recurring-transactions';
  static const String pendingRecurrings = '/pending-recurrings';
  static const String syncPush = '/sync/push';
  static const String syncPull = '/sync/pull';
  static const String syncSummary = '/sync/summary';
  static const String syncClear = '/sync/clear';
  static const String health = '/health';

  /// Returns the configured backend base URL.
  ///
  /// In debug mode, falls back to localhost if BACKEND_URL is missing.
  /// In release/profile builds, throws a [StateError] if BACKEND_URL is
  /// missing or not HTTPS, to prevent silent misconfiguration.
  static String get baseUrl {
    final value = dotenv.env['BACKEND_URL'];
    if (value == null || value.isEmpty || value == 'TBD') {
      if (kDebugMode) {
        return 'http://localhost:3000/api';
      }
      throw StateError(
        'BACKEND_URL is not configured. '
        'Set it in .env.prod for release builds.',
      );
    }

    if (!kDebugMode && !value.startsWith('https://')) {
      throw StateError(
        'BACKEND_URL must use HTTPS in release builds. '
        'Got: ${value.split('://').first}://',
      );
    }

    return value;
  }

  static String categoryIncrementUsage(String id) =>
      '/categories/$id/increment-usage';

  static String budgetProgress(String id) => '/budgets/$id/progress';
}
