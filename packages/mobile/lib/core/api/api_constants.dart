import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String login = '/auth/login';
  static const String deleteAccount = '/auth/account';

  static const String deletedUserMessage = 'User no longer exists';

  static const String healthStatusKey = 'status';
  static const String healthOk = 'ok';

  static const String recordBudgetLinks = '/records/budget-links';
  static const String budgetNames = '/budgets/names';
  static const String syncPush = '/sync/push';
  static const String syncPull = '/sync/pull';
  static const String syncSummary = '/sync/summary';
  static const String syncClear = '/sync/clear';
  static const String health = '/health';
  static const String groups = '/groups';
  static const String groupsMe = '/groups/me';
  static const String groupsJoin = '/groups/join';

  static String get baseUrl {
    final value = dotenv.env['BACKEND_URL'];
    if (value == null || value.isEmpty || value == 'TBD') {
      if (!kReleaseMode) {
        return 'http://localhost:3000/api';
      }
      throw StateError(
        'BACKEND_URL is not configured. '
        'Set it in .env.prod for release builds.',
      );
    }

    if (kReleaseMode && !value.startsWith('https://')) {
      throw StateError(
        'BACKEND_URL must use HTTPS in release builds. '
        'Got: ${value.split('://').first}://',
      );
    }

    return value;
  }

  static String group(String id) => '/groups/$id';

  static String groupInvites(String id) => '/groups/$id/invites';

  static String groupMember(String id, String userId) =>
      '/groups/$id/members/$userId';

  static String groupSummary(String id) => '/groups/$id/summary';
}
