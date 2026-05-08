import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000/api';
  static const String login = '/auth/login';
  static const String records = '/records';
  static const String recordsBulk = '/records/bulk';
  static const String categories = '/categories';
  static String categoryIncrementUsage(String id) => '/categories/$id/increment-usage';
  static const String budgets = '/budgets';
  static String budgetProgress(String id) => '/budgets/$id/progress';
  static const String messageSources = '/message-sources';
  static const String expenseTemplates = '/expense-templates';
  static const String parsingRules = '/parsing-rules';
  static const String recurringTransactions = '/recurring-transactions';
  static const String pendingRecurrings = '/pending-recurrings';
  static const String syncPush = '/sync/push';
  static const String syncPull = '/sync/pull';
  static const String syncSummary = '/sync/summary';
  static const String syncClear = '/sync/clear';
}
